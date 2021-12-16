# frozen_string_literal: true

class FeedItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :itemizable, polymorphic: true
  has_and_belongs_to_many :feeds, inverse_of: :items

  field :parent_id, type: BSON::ObjectId

  scope :post,   -> { where(itemizable_type: 'Post') }
  scope :user,   -> { where(itemizable_type: 'User') }
  scope :parent, ->(parent_id) { post.where(parent_id: parent_id) }

  validates :itemizable_id, uniqueness: { scope: :itemizable_type }

  with_options if: :type_post? do
    before_create :set_parent_id
    after_create  :add_post_to_feed
    after_touch   :remove_from_feed, :add_post_to_feed
  end

  after_destroy :remove_from_feed

  def self.discover
    # TODO: order... load views?
    ids(:post, Post.most_viewed_ids) + ids(:user, User.most_viewed_ids)
  end

  def self.ids(type, ids)
    return [] unless %i[post user].include?(type)

    send(type).for(ids).pluck(:id)
  end

  def self.for(ids)
    self.in(itemizable_id: ids)
  end

  private

  def add_post_to_feed
    return unless type_post?

    profile_feed = ProfileFeed.profile.where(user: itemizable.user, type: itemizable.feed_type)
    profile_feed.add_item(id)
    itemizable.user.touch # rubocop:disable Rails/SkipsModelValidations
  end

  def type_post?
    itemizable_type == 'Post'
  end

  def remove_from_feed
    feed = Feed.in(feed_item_ids: id)

    itemizable.user.touch if type_post? # rubocop:disable Rails/SkipsModelValidations
    feed.remove([id])
  end

  def set_parent_id
    self.parent_id = itemizable.original_post_id
  end
end
