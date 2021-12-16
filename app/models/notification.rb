# frozen_string_literal: true

class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  belongs_to :recipient,  class_name: 'User', inverse_of: :notifications
  belongs_to :actor,      class_name: 'User', inverse_of: :acted_notifications
  belongs_to :notifiable, polymorphic: true

  field :read_at, type: DateTime
  field :headings, type: String
  field :description, type: String
  field :image_url, type: String
  field :notifiable_url, type: String
  enum :action, [:followed, :mentioned, :commented, :added_takko, :upvoted, :payout, :followee_posted]

  scope :for, ->(u) { where(recipient: u).not_in(actor_id: u.block_user_ids) }
  scope :unread, -> { where(read_at: nil) }
  scope :last_three_month, -> { where(:created_at.gt => 3.months.ago) }
  scope :without_payout, -> { where.not(action: :payout) }

  after_create :expire_cache

  validates :action, presence: true
  validates :recipient, uniqueness: { scope: [:actor, :notifiable, :action], message: "can't create duplicate notification" }, if: :no_duplicate?
  validate :cannot_notify_self, if: -> { recipient && actor }

  def self.expire_unread_count(user_id)
    Rails.cache.delete("users/#{user_id}/unread_notifications_count")
  end

  def expire_cache
    self.class.expire_unread_count(recipient_id)
  end

  def no_duplicate?
    %i[followed upvoted].include?(action)
  end

  private

  def cannot_notify_self
    return unless recipient == actor

    errors.add(:base, "Can't create notification for self")
  end
end
