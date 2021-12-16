class ProfileFeed < Feed
  include Mongoid::Enum

  enum :type, %i(public_post public_takko followees private)

  alias :items :posts

  validates :type, :user, presence: true
  validates :type, uniqueness: { scope: :user }

  def self.init!(user)
    types.each { |t| user.profile_feed.send(t).create! }
  end

  def self.private_items(user)
    private_feed  = user.profile_feed.in(type: %i(followees private))
    feed_item_ids = private_feed.reduce([]) { |a,f| a + f.feed_item_ids }
    posts(FeedItem.in(id: feed_item_ids))
  end
end
