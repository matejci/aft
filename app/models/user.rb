# frozen_string_literal: true

class User # rubocop:disable Metrics/ClassLength
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include User::Search
  include Followable
  include Mongoid::History::Trackable

  track_history on: %i[monetized_at monetization_status monetization_status_type], modifier_field: nil

  POST_FIELDS = %w[username display_name profile_image profile_image_version verified].freeze
  REQUIRED_FIELDS = %i[birthdate username display_name password verified_email verified_phone].freeze

  belongs_to :user_group, inverse_of: :users, optional: true

  has_one :paypal_account, dependent: :destroy, autobuild: true
  has_one :email_verification, dependent: :destroy
  has_one :phone_verification, dependent: :destroy
  has_one :feed_item, as: :itemizable, dependent: :destroy
  has_one :invitation, autosave: true, dependent: :nullify
  has_one :configuration, class_name: 'UserConfiguration', dependent: :destroy, autobuild: true

  has_many :feed, dependent: :destroy
  has_many :profile_feed, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :views, dependent: :nullify
  has_many :watch_times, dependent: :nullify
  has_many :mentions, dependent: :destroy
  has_many :my_mentions, class_name: 'Mention', foreign_key: :mentioned_by_id, dependent: :destroy, inverse_of: :mentioned_by

  has_many :notifications, foreign_key: :recipient_id, inverse_of: :recipient, dependent: :destroy
  has_many :acted_notifications, class_name: 'Notification', foreign_key: :actor_id, inverse_of: :actor, dependent: :destroy
  has_many :payout_notifications, as: :notifiable, class_name: 'Notification', dependent: :destroy

  has_many :blocks, dependent: :destroy
  has_many :blocking, class_name: 'Block', dependent: :destroy, foreign_key: :blocked_by_id, inverse_of: :blocked_by
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :payouts, dependent: :restrict_with_exception
  has_many :usernames, validate: false, dependent: :nullify
  has_many :devices, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :user_groups, dependent: :destroy
  has_many :contests, dependent: :nullify
  has_many :shares, dependent: :destroy

  has_and_belongs_to_many :pools
  has_and_belongs_to_many :pool_intervals

  field :ip_address, type: String
  field :last_activity, type: DateTime

  field :first_name, type: String
  field :last_name, type: String

  field :bio, type: String
  field :website, type: String

  field :dob, type: Date
  field :ssn_last_4, type: String

  field :email, type: String
  field :phone, type: String
  field :password_hash, type: String
  field :password_salt, type: String
  field :email_verified_at, type: DateTime
  field :phone_verified_at, type: DateTime

  mount_uploader :profile_image,    ProfileImageUploader
  mount_uploader :background_image, BackgroundImageUploader

  # file upload/version identifier
  field :profile_image_version, type: String, default: 'default'
  field :background_image_version, type: String

  field :verified, type: Boolean, default: false # public figure, celebrity or global brand

  field :password_verification_token, type: String

  field :username, type: String
  field :display_name, type: String

  field :monetized_at, type: DateTime
  field :monetization_status, type: Boolean, default: false
  enum  :monetization_status_type, %i[not_started off pending paused enabled denied disabled takko_restricted], default: :not_started

  field :tos_acceptance, type: Boolean
  field :tos_acceptance_date, type: DateTime
  field :tos_acceptance_ip, type: String

  field :admin, type: Boolean, default: false
  field :completed_signup, type: Boolean, default: false

  # takko managed account
  field :force_index,   type: Boolean, default: false
  field :takko_managed, type: Boolean, default: false

  # update timestamps
  field :block_updated_at,  type: DateTime
  field :follow_updated_at, type: DateTime

  field :creator_program_opted, type: Boolean
  field :creator_program_opted_at, type: DateTime

  field :removal_requested_at, type: DateTime
  field :removal_deactivation_at, type: DateTime
  field :removal_ip_address, type: String
  field :removal_user_agent, type: String

  field :comments_count, type: Integer, default: 0
  field :votes_count, type: Integer, default: 0
  field :counted_watchtime, type: Float, default: 0

  enum :removal_reason, %i[user_requested]
  enum :acct_status, %i[active deactivated deleted restricted], default: :active
  enum :admin_role, %i[basic support manager administrator super_administrator non_admin], default: :non_admin

  index email: 1
  index phone: 1
  index username: 1

  attr_accessor :birthdate, :claiming, :invite, :user_agent, :password, :new_password, :new_password_confirmation, :password_token

  # scopes
  scope :can_monetize, -> { where(monetization_status: true) }
  scope :valid, -> { where(completed_signup: true).or(takko_managed: true).not(acct_status: :deleted) }
  scope :active, -> { valid.and(acct_status: :active) }

  # validations
  validate :email_or_phone_present, :birthdate_to_dob, :at_least_13, :valid_email, :valid_phone
  validates :first_name, :last_name, :display_name, length: { maximum: 30, message: 'Max character limit is 30' }
  validates :ssn_last_4, presence: true, if: :ssn_last_4_changed?
  validates :ssn_last_4, digits: { length: { is: 4 } }
  validates :display_name, presence: true, if: :display_name_changed?

  # check for uniqueness scoped to valid(completed signup) accounts

  validates :username, presence: true, username_format: true, if: :username_changed?

  # TODO, refactor this... with_options block doesn't work with unique_validator
  validates :username, unique: { conditions: -> { valid },
                                 across: { name: { model: -> { Username.distinct_set } } } }, if: :username_changed?

  validate :valid_password
  validate :validate_tos_acceptance, if: :tos_acceptance_changed?

  validate :profile_image_file_versioning,     if: :profile_image_changed?
  validate :background_image_file_versioning,  if: :background_image_changed?

  validates :birthdate, presence: { message: 'Please enter your date of birth' }, if: :birthdate, unless: :takko_managed?

  with_options if: :takko_managed? do
    validate     :cannot_change_username
    after_create :follow_takko, :prep_feed
  end

  with_options if: :claiming do
    before_validation :reset_takko_managed
    validate :finished_signup?
  end

  # callbacks
  before_validation :validate_invite, if: :invite
  before_validation :email_downcase, if: :email_changed?

  before_destroy :remember_id
  after_destroy :remove_id_directory
  after_save :feed_featurable, if: :force_index_changed?
  after_save :update_username, if: :username_changed?
  after_save :touch_feed_item, :touch_posts, if: :visible_fields_changed?

  def self.find_with(email_or_phone)
    type = EmailFormatValidator::REGEX.match(email_or_phone) ? :email : :phone
    regex = /^#{::Regexp.escape(email_or_phone)}$/i

    User.valid.find_by(type => regex)
  end

  def active_account?
    valid_account? && active?
  end

  def valid_account?
    completed_signup? || takko_managed?
  end

  def account_errors
    finished_signup? unless valid_account? # load incomplete errors
    errors
  end

  def admin?
    !non_admin?
  end

  def self.aft_user
    Rails.cache.fetch('aft-user') do
      active.find_by(username: 'aft-user')
    end
  end

  def feed_featurable(featurable = should_index?)
    if featurable
      create_feed_item if feed_item.nil?
    else
      feed_item&.destroy
    end
  end

  def full_name
    [first_name, last_name].compact.map(&:capitalize).join(' ')
  end

  def profile_image_file_versioning
    self.profile_image_version = loop do
      token = SecureRandom.hex(5)
      break token unless User.where(profile_image_version: token).exists?
    end
  end

  def background_image_file_versioning
    self.background_image_version = loop do
      token = SecureRandom.hex(5)
      break token unless User.where(background_image: token).exists?
    end
  end

  # Profile

  # TODO: define counter cache fields with conditions

  def posts_count
    posts.active.original.where(view_permission: :public).count
  end

  def takkos_count
    posts.active.takko.where(view_permission: :public, own_takko: false).count
  end

  # Feed

  ProfileFeed.types.each do |type|
    # ex. profile_public_post
    define_method("profile_#{type}") { profile_feed.send(type).first }
  end

  def private_posts(viewer)
    if self == viewer
      ProfileFeed.private_items(self)
    else
      ActivePostsQuery.new(profile_followees.items, viewer).call
    end
  end

  def self.most_viewed_ids
    Rails.cache.fetch('users/most_viewed_ids', expires_in: 5.minutes) do
      Post.collection.aggregate([
                                  { '$match': { '$and': [{ active: true }, { view_permission: :public }] } },
                                  { '$group': { _id: '$user_id', views: { '$sum': '$total_views' } } },
                                  { '$sort': { views: -1 } },
                                  { '$limit': 20 }
                                ]).pluck(:_id)
    end
  end

  def touch_feed_item
    feed_item&.touch
  end

  def authenticate(password)
    if password_hash.nil?
      errors.add(:password, :not_setup)
    elsif password.blank?
      errors.add(:password, :required)
    elsif password_hash != BCrypt::Engine.hash_secret(password, password_salt)
      errors.add(:password, :wrong)
    end

    errors.exclude?(:password)
  end

  def block!(user)
    blocking.create(user: user)
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def finished_signup?
    return if completed_signup

    REQUIRED_FIELDS.each do |field|
      case field
      when :password
        errors.add(:password, 'missing password') if password_hash.blank?
      when :birthdate
        errors.add(:birthdate, 'missing birthdate') if dob.blank?
      when :verified_email
        errors.add(:email, 'unverified email') if email.present? && email_verified_at.nil?
      when :verified_phone
        errors.add(:phone, 'unverified phone') if phone.present? && phone_verified_at.nil?
      else
        validates_presence_of field unless errors.include?(field)
      end
    end

    errors.empty?
  end

  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def unblock!(user)
    blocking.where(user: user).destroy_all
  end

  def blocked?(user)
    return unless user

    blocked_user_ids.include?(user.id)
  end

  def blocked_or_blocked_by?(user)
    return unless user

    user_id = user.is_a?(User) ? user.id : user
    block_user_ids.include?(user_id)
  end

  def block_user_ids
    # users blocked by them + users who blocked them
    Rails.cache.fetch("#{cache_key}/block_user_ids") do
      blocked_user_ids + blocks.pluck(:blocked_by_id)
    end
  end

  def blocked_user_ids
    Rails.cache.fetch("#{cache_key}/blocked_user_ids") do
      blocking.pluck(:user_id)
    end
  end

  def blocked_users
    User.in(id: blocked_user_ids)
  end

  def follow_takko
    follow! User.find_by(username: 'aftuser')
  end

  def follow_url
    Rails.application.routes.url_helpers.follow_profile_url(username, host: ENV['URL_BASE'])
  end

  def expire_most_viewed_cache
    user_ids = Rails.cache.read('users/most_viewed_ids')
    Rails.cache.delete('users/most_viewed_ids') if user_ids&.include?(id)
  end

  def profile_thumb_url
    profile_image.try(:url, :thumb)
  end

  def validate_tos_acceptance
    errors.add(:tos_acceptance, 'Required') unless tos_acceptance
  end

  def unread_notifications_count
    Rails.cache.fetch("users/#{id}/unread_notifications_count") do
      notifications.unread.count
    end
  end

  def email_downcase
    return if email.blank?

    self.email = email.downcase
  end

  protected

  def remember_id
    @id = id
  end

  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/profile_image/#{@id}", force: true)
    FileUtils.remove_dir("#{Rails.root}/public/background_image/#{@id}", force: true)
  end

  private

  def at_least_13
    return unless dob_changed? && dob > 13.years.ago.to_date

    errors.add(birthdate ? :birthdate : :dob, 'You must be at least 13 years old to sign up')
  end

  def birthdate_to_dob
    return unless birthdate

    self.dob = Date.strptime(birthdate, '%Y-%m-%d')
  rescue Date::Error
    errors.add(:birthdate, 'should be formatted YYYY-MM-DD')
  end

  def cannot_change_username
    return unless username_changed? && username_was.present?

    errors.add(:username, "can't change username on managed user account")
  end

  def claim_invitation
    return if (ENV['HEROKU_ENV'] == 'staging') || invitation.blank? || invitation.skip_claiming?

    throw(:abort) unless invitation.claim
  end

  def email_or_phone_present
    errors.add(:base, 'Email or Phone Number is required') unless email.present? || phone.present?
  end

  def prep_feed
    ProfileFeed.init!(self) # create profile feed
  end

  def reset_takko_managed
    self.force_index   = false
    self.takko_managed = false
  end

  def update_username
    return unless (claimed_username = Username.claimed_by(id))

    claimed_username.set(alias: true)
  end

  def validate_invite
    return if invitation&.user == self # valid invitation already exists

    if invite.present?
      self.invitation = Invitation.find_by(invite_code: invite)

      if invitation
        invitation.ip_address = ip_address
        invitation.user_agent = user_agent
        invitation.user = self

        if invitation.claimed
          invitation.log_attempt
          errors.add(:invite, 'This invite code is no longer valid')
        end
      else
        errors.add(:invite, 'Invite code is invalid')
      end
    else
      errors.add(:invite, 'Invite code required')
    end
  end

  def valid_email
    FieldValidatorService.new(user: self, email: email).call if email_changed?
  end

  def valid_phone
    FieldValidatorService.new(user: self, phone: phone).call if phone_changed?
  end

  def visible_fields_changed?
    # TODO: check if profile_image changes
    (changes.keys & POST_FIELDS).any?
  end

  def touch_posts
    posts.update_all(updated_at: Time.current)
  end

  def valid_password
    PasswordValidatorService.new(user: self).call if password || new_password
  end
end
