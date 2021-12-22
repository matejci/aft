# frozen_string_literal: true

class Post # rubocop:disable Metrics/ClassLength
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include Post::Permission
  include Post::Search
  include Taggable

  taggable_fields %w[title description]

  MINIMUM_VIDEO_LENGTH = 3
  MAXIMUM_VIDEO_LENGTH = 60

  ORDER_HASH = {
    comments: { comments_count: :desc },
    newest: { publish_date:   :desc },
    oldest: { publish_date:   :asc  },
    upvotes: { upvotes_count: :desc },
    views: { total_views: :desc },
    watchtime: { counted_watchtime: :desc }
  }.freeze

  has_and_belongs_to_many :hashtags
  has_many :comments, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :upvotes,                         dependent: :destroy
  has_many :downvotes,                       dependent: :destroy
  has_many :notifications, as: :notifiable,  dependent: :destroy

  # TODO: should not delete views, view will belong to archived post
  has_many :view_trackings,                  dependent: :destroy
  has_many :views,                           dependent: :destroy
  has_many :watch_times,                     dependent: :destroy
  has_many :contests, dependent: :nullify
  has_many :shares, dependent: :destroy

  #  by default, Mongoid will validate the children of any association that are loaded into memory
  has_many   :takkos, class_name: 'Post', inverse_of: :parent, dependent: :destroy, validate: false
  belongs_to :parent, class_name: 'Post', optional: true, touch: true
  belongs_to :original_user, class_name: 'User', optional: true # used for view permission check

  belongs_to :user
  belongs_to :category, optional: true

  # status flags
  field :active,       type: Boolean, default: false
  field :archived,     type: Boolean, default: false # user destroying post
  field :archived_at,  type: DateTime
  field :completed,    type: Boolean, default: false # required data all received
  field :publish,      type: Boolean, default: false
  field :publish_date, type: DateTime
  field :status,       type: Boolean, default: true  # admin flagging post
  field :video_transcoded, type: Boolean, default: false

  field :title, type: String
  field :description, type: String
  field :video_length, type: Float # in seconds
  field :own_takko, type: Boolean
  field :feed_item_id, type: String

  mount_uploader :media_file, MediaUploader
  mount_uploader :media_thumbnail, MediaThumbnailUploader
  mount_uploader :animated_cover, AnimatedCoverUploader

  field :media_type, type: String
  field :animated_cover_offset, type: Float
  field :link, type: String
  field :link_title, type: String
  field :allow_comments, type: Boolean, default: true

  # count fields
  field :comments_count,    type: Integer, default: 0
  field :upvotes_count,     type: Integer, default: 0
  field :total_views,       type: Integer, default: 0 # sum of views' counted views
  field :counts_updated_at, type: DateTime
  field :counted_watchtime, type: Float, default: 0
  field :shares_count, type: Integer, default: 0

  field :media_thumbnail_dimensions, type: Hash

  # enum :takko_order, %i[oldest newest upvotes comments views], default: :oldest
  enum :takko_order, %i[oldest newest], default: :oldest

  alias deleted archived
  alias_attribute :text, :description

  attr_accessor :archiving, :viewer_group_ids, :takkoer_group_ids, :takkos_received

  index category_id: 1
  index link: 1

  scope :active,    -> { where(active: true) }
  scope :original,  -> { where(parent_id: nil) }
  scope :takko,     -> { where.not(parent_id: nil) } # takko belongs to parent (original post)
  scope :without_tutorials, -> { where.not(category_id: Category.tutorial.first.id) }
  scope :allowed, -> { where(status: true) }

  before_validation :set_default_category, if: -> { category_id == 'default' }
  before_validation :set_original_user,    if: :user_id_changed?

  validates :category, :media_file, :title, :video_length, presence: { message: 'is required' }
  validates :video_length, numericality: { greater_than: MINIMUM_VIDEO_LENGTH, less_than_or_equal_to: MAXIMUM_VIDEO_LENGTH }, if: :video_length
  validate :generate_link, on: :create

  with_options if: :title_changed? do
    validate :process_title
    validate :process_link_title
  end

  with_options if: :parent_id_changed? do
    before_validation :correct_parent, :inherit_from_parent
    validates_with TakkoValidator
  end

  before_save  :complete_posting, unless: :completed?
  before_save  :update_active

  after_update :expire_most_viewed_cache, :expire_user_cache

  before_destroy :remember_id

  after_destroy :destroy_notification, :reindex
  after_destroy :remove_id_directory

  after_save   :reindex, if: :searchable_fields_changed?
  after_save   :destroy_dependents, :destroy_notification, if: :archiving

  def self.most_viewed_ids
    # attempts to run through for most recent
    time_based_attempts = [1.week.ago, 2.weeks.ago, 3.weeks.ago, 1.month.ago, 2.months.ago]

    # declaring var and setting default if there are not enough posts from the time based attempts
    most_viewed_recent = Post.view_public.active
    time_based_attempts.each do |time|
      most_viewed_recent = Post.view_public.active.where(:publish_date.gt => time)
      break most_viewed_recent unless most_viewed_recent.size < 20
    end

    Rails.cache.fetch('posts/most_viewed_ids', expires_in: 5.minutes) do
      most_viewed_recent.post_order(:views).limit(20).pluck(:id)
    end
  end

  def self.sort_option(key)
    ORDER_HASH.with_indifferent_access[key] || key
  end

  # cache keys
  # NOTE: don't use touch(:counts_updated_at) or `touch: :counts_updated_at`
  # since we only want to touch `counts_updated_at` and not `updated_at`
  # counts get updated way more often than post

  def counts_updated_at
    super || updated_at
  end

  def counts_cache_key
    "post_counts/#{id}-#{counts_updated_at.to_s(cache_timestamp_format)}"
  end

  def max_cache_key
    max_updated_at = [counts_updated_at, updated_at].max
    "post_max/#{id}-#{max_updated_at.to_s(cache_timestamp_format)}"
  end

  def complete_posting
    self.completed = true

    return if publish_date.present? # unless scheduled to publish later

    self.publish = true
    self.publish_date = Time.current
  end

  def original_post_id
    takko? ? parent_id : id
  end

  def process_title
    return if title.blank?

    # remove line breaks and extra whitespace
    self.title = title.squish
  end

  def process_link_title
    self.link_title = title.downcase.parameterize if title.present?
  end

  def generate_link
    self.link = loop do
      token = SecureRandom.hex(4)
      break token unless Post.where(link: token).exists?
    end
  end

  def link_url
    Rails.application.routes.url_helpers.p_url(link, format: :json)
  end

  def media_thumbnail_url
    media_thumbnail.try(:url, :thumb)
  end

  def original?
    parent_id.nil?
  end

  def takko?
    !original?
  end

  def type
    takko? ? 'takko' : 'post'
  end

  def feed_type
    # own public takko belongs to public post, not profile
    return if view_public? && own_takko?

    view_public? ? "public_#{type}" : view_permission
  end

  protected

  def remember_id
    @id = id
  end

  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/media_file/#{@id}", force: true)
    FileUtils.remove_dir("#{Rails.root}/public/media_thumbnail/#{@id}", force: true)
  end

  private

  def destroy_dependents
    comments.destroy_all
    mentions.destroy_all
  end

  def destroy_notification
    notifications.destroy_all
  end

  def public_active?
    active? && view_public?
  end

  def was_public_active?
    active_was && view_permission_was == :public
  end

  def public_active_changed?
    was_public_active? && !public_active?
  end

  def expire_most_viewed_cache
    post_ids = Rails.cache.read('posts/most_viewed_ids')
    # expire cache if post information changed
    Rails.cache.delete('posts/most_viewed_ids') if post_ids&.include?(id)
  end

  def expire_user_cache
    # expire cache if user deactived(private or unpublished) most viewed posts
    user.expire_most_viewed_cache if public_active_changed?
  end

  def correct_parent
    self.parent = parent.parent if parent&.takko? # nesting is not allowed
  end

  def inherit_from_parent
    return if parent.blank?

    self.category    ||= parent.category
    self.original_user = parent.user
    self.own_takko     = parent.owner?(user)
  end

  def set_default_category
    self.category ||= Category.first || Category.create!(name: 'Default')
  end

  def set_original_user
    return unless original?

    self.original_user = user
  end

  def searchable_fields_changed?
    visible_fields_changed? || active_changed? || view_permission_changed?
  end

  def update_active
    return unless (changes.keys & %w[completed status publish archived]).any?

    self.active = completed && status && publish && !archived
  end

  def visible_fields_changed?
    (changes.keys & %w[title description user_id]).any?
  end
end
