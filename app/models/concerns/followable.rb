# frozen_string_literal: true

module Followable
  extend ActiveSupport::Concern

  included do
    has_many :followed_users, foreign_key: :followee_id, class_name: 'Follow',
                              inverse_of: :followee, dependent: :destroy
    has_many :following_users, foreign_key: :follower_id, class_name: 'Follow',
                               inverse_of: :follower, dependent: :destroy

    field :followees_count, type: Integer, default: 0
    field :followers_count, type: Integer, default: 0
  end

  def followees
    User.in(id: followees_ids)
  end

  def followers
    User.in(id: followers_ids)
  end

  def followers_ids
    Rails.cache.fetch("#{cache_key}/followers_ids") do
      followed_users.pluck(:follower_id).map(&:to_s)
    end
  end

  def followees_ids
    Rails.cache.fetch("#{cache_key}/followees_ids") do
      following_users.pluck(:followee_id).map(&:to_s)
    end
  end

  def follow!(followee)
    return unless followee

    following_users.create(followee: followee)
  end

  def unfollow!(followee)
    return unless followee

    following_users.find_by(followee: followee).try(:destroy!)
  end

  def follows?(user)
    return unless user

    followees_ids.include?(user.id.to_s) ? true : false
  end
end
