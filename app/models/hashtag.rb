# frozen_string_literal: true

class Hashtag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Hashtag::Search

  has_and_belongs_to_many :comments
  has_and_belongs_to_many :posts
  belongs_to :category, optional: true
  belongs_to :created_by, class_name: 'User', optional: true # created/submitted by which user

  field :name, type: String
  field :link, type: String

  # hashtag status
  field :status, type: Boolean, default: true
  field :takeover, type: Boolean, default: false

  validates :name, presence: { message: 'Required' }, length: { maximum: 120 }

  validate :set_parameterize_link, on: :create, unless: proc { |h| h.name.nil? } # unless hashtag name is nil
  validate :update_parameterize_link, on: :update

  def set_parameterize_link
    # turn category name into link
    parameterized_link = name.downcase.parameterize
    increment_link(parameterized_link)
  end

  def update_parameterize_link
    if name_changed?
      parameterized_link = name.downcase.parameterize
      increment_link(parameterized_link)
    elsif link_changed?
      parameterized_link = link
      increment_link(parameterized_link)
    end
  end

  def increment_link(parameterized_link)
    # if same hashtag link exists add a number until unique
    num = 0

    self.link = loop do
      incremental_link = if num.zero?
        parameterized_link
      else
        "#{parameterized_link}-#{num}"
      end

      num += 1

      break incremental_link unless Hashtag.where(link: incremental_link).exists?
    end
  end
end
