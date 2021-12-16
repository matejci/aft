# frozen_string_literal: true

class Follow
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :followee, class_name: 'User', inverse_of: :followed_users,
                        counter_cache: :followers_count, touch: :follow_updated_at
  belongs_to :follower, class_name: 'User', inverse_of: :following_users,
                        counter_cache: :followees_count, touch: :follow_updated_at

  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :follower_id, uniqueness: { scope: :followee_id,
                                        message: 'Follow already exists' }
  validate :allowed_to_follow

  def allowed_to_follow
    return unless follower && followee

    if follower == followee
      errors.add(:follower_id, "Can't follow self")
    elsif Block.exists_for?(follower, followee)
      errors.add(:base, 'Not allowed to follow')
    end
  end
end
