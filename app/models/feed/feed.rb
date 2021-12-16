# frozen_string_literal: true

class Feed
  include Mongoid::Document
  include Mongoid::Timestamps

  scope :profile, -> { where(_type: 'ProfileFeed') }

  belongs_to :user, optional: true
  has_and_belongs_to_many :feed_items

  def self.add_item(id)
    criteria.push(feed_item_ids: id)
    update_all(updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def self.posts(feed_items)
    Post.in(id: feed_items.post.pluck(:itemizable_id))
        .includes(:category, :user, :parent)
        .desc(:publish_date)
  end

  def self.remove(feed_item_ids)
    return if feed_item_ids.blank?

    # NOTE: need to select feed by ids so `feed` does not change when feed_item is pulled
    feed = Feed.in(id: pluck(:id))
    feed.pull_all(feed_item_ids: feed_item_ids)
    feed.update_all(updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def post_ids
    feed_items.post.pluck(:itemizable_id)
  end

  def posts
    self.class.posts(feed_items)
  end
end
