# frozen_string_literal: true

class Block
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, inverse_of: :blocks, touch: :block_updated_at
  belongs_to :blocked_by, class_name: 'User', inverse_of: :blocking, touch: :block_updated_at

  validates :blocked_by, uniqueness: { scope: :user, message: 'Account has already been blocked' }
  validate  :cannot_block_self

  after_create :remove_follow

  def self.exists_for?(user_a, user_b)
    any_of({ user: user_a, blocked_by: user_b }, { user: user_b, blocked_by: user_a }).exists?
  end

  private

  def cannot_block_self
    return unless user == blocked_by

    errors.add(:base, "Can't block self")
  end

  def remove_follow
    Follow.where(follower: user, followee: blocked_by).destroy
    Follow.where(follower: blocked_by, followee: user).destroy
  end
end
