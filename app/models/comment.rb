# frozen_string_literal: true

class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  include Taggable
  taggable_fields %w[text]

  belongs_to :user, optional: true, counter_cache: true
  belongs_to :post, counter_cache: :comments_count
  belongs_to :phantom_by, class_name: 'User', optional: true

  has_many :notifications, as: :notifiable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy
  has_many :upvotes, dependent: :destroy

  field :text, type: String
  field :rich_text, type: String
  field :link, type: String
  field :status, type: Boolean, default: true
  field :phantom, type: Boolean, default: false
  field :upvotes_count, type: Integer, default: 0

  index link: 1

  scope :active,      -> { where(status: true, phantom: false) }
  scope :not_blocked, ->(u) { not_in(user_id: u&.block_user_ids) }

  with_options on: :create do
    validates :text, presence: { message: 'Required' }
    validates :user, presence: true
    validate :set_link
  end

  validate :allowed_to_comment
  validate :auto_link, if: :text_changed?

  before_validation :set_phantom, if: :phantom_by_id_changed?

  after_create  :touch_post_counts_updated_at
  after_destroy :touch_post_counts_updated_at

  before_destroy do
    throw(:abort) if reports.any?
  end

  # process rich_text
  def auto_link
    if Rails.env.in?(%w[development test])
      url_base = 'http://localhost:3000/'
    elsif Rails.env.production?
      url_base = ENV['URL_BASE'] || 'https://appforteachers.com/'
    end

    self.rich_text = Twitter::TwitterText::Autolink.auto_link(text.to_s, { username_class: 'takkoURL username',
                                                                           list_class: 'takkoURL list',
                                                                           hashtag_class: 'takkoURL hashtag',
                                                                           cashtag_class: 'takkoURL cashtag',
                                                                           username_url_base: "#{url_base}profiles/",
                                                                           hashtag_url_base: "#{url_base}search?q=",
                                                                           list_url_base: url_base,
                                                                           cashtag_url_base: url_base,
                                                                           username_include_symbol: true })
  end

  def link_url
    Rails.application.routes.url_helpers.p_url(post.link, comment_id: id, format: :json)
  end

  # generate comment permalink
  def set_link
    self.link = loop do
      token = SecureRandom.hex(4)
      break token unless Comment.where(link: token).exists?
    end
  end

  private

  def allowed_to_comment
    return if post.blank?

    if post.allow_comments
      errors.add(:base, 'Not allowed to comment') if Block.exists_for?(post.user, user)
    else
      errors.add(:base, 'Commenting not allowed on this post')
    end
  end

  def set_phantom
    if phantom_by.nil?
      self.phantom = false
    elsif phantom_by == post.user # later moderators can phantom as well
      self.phantom = true
    else
      errors.add(:phantom_by, 'Only post owner can phantom comments')
    end
  end

  def touch_post_counts_updated_at
    post.set(counts_updated_at: Time.current)
  end
end
