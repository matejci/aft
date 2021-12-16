# frozen_string_literal: true

class Username
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  USER_SCOPE = { model: -> { User.valid }, except: { id: :user_id } }.freeze

  belongs_to :user, optional: true

  delegate :email, to: :user, allow_nil: true, prefix: :user

  accepts_nested_attributes_for :user, update_only: true
  validates_associated :user

  scope :alias_set,    -> { where(alias: true) }
  scope :distinct_set, -> { where(user: nil).or(alias_set) }

  field :alias,         type: Boolean, default: false
  field :name,          type: String
  field :status,        type: Boolean, default: true
  field :temp_password, type: String

  enum :type, %i[hold reserved manage claimed], default: :hold
  # hold:     on hold and if not assigned to anyone specifically
  # reserved: reserved for a specific person
  # manage:   has a user account that's managed by takko
  # claimed:  user claimed the user account

  attr_accessor :email, :file, :start_managing

  validates :name, presence: true,
                   username_format: true,
                   unique: { conditions: -> { distinct_set }, across: { username: USER_SCOPE } }

  validates :email, email_format: true, unique: { across: { email: USER_SCOPE } }
  validates :user,  presence: true, if: :should_attach?
  validates :user,  uniqueness: { scope: :alias }, if: :attached_non_alias?

  with_options if: :start_managing do
    validates :email, presence: true
    validate  :already_managing

    before_save :create_user, :set_manage
  end

  after_destroy :reindex_user, if: :alias?
  after_save    :reindex_user, if: -> { alias_changed? || user_id_changed? }

  def self.claimed_by(id)
    claimed.find_by(alias: false, user: id)
  end

  # bulk upload usernames
  def self.import(file)
    require 'csv'

    CSV.foreach(file.path, headers: true) do |row|
      username_hash = Username.new
      username_hash.name = row[0]
    end
  end

  def self.manage_user(attrs)
    username = Username.find_or_initialize_by(name: attrs[:name])
    username.attributes = attrs
    username.start_managing = true
    username.save
    username
  end

  def attached_non_alias?
    user && !alias?
  end

  def claim!(user_attrs)
    self.attributes = user_attrs
    user.claiming = true
    self.type = :claimed
    save
  end

  def searchable_user!(searchable)
    return if user.blank?

    user.force_searchable(searchable)
    user.feed_featurable
  end

  def should_attach?
    return if start_managing

    alias? || %i[manage claimed].include?(type)
  end

  private

  def already_managing
    errors.add(:base, "already managing user: #{user.email}") if manage? && user.present?
  end

  def create_user
    self.user = User.create(email: email, username: name, password: generate_temp_password, takko_managed: true)
  end

  def generate_temp_password
    self.temp_password = SecureRandom.alphanumeric(7)
  end

  def reindex_user
    User.find(user_id_was)&.reindex(:search_alias_usernames) if user_id_changed? && user_id_was
    user&.reindex(:search_alias_usernames)
  end

  def set_manage
    self.type = :manage
  end
end
