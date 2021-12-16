# frozen_string_literal: true

module PushNotifications
  class FollowerJob < ApplicationJob
    queue_as :push_notifications
    sidekiq_options retry: 2

    def perform(post_id:, recipient_id:)
      @post = Post.active.includes(:user).find(post_id)
      @recipient = User.active.find(recipient_id)

      return unless @post && @recipient

      notify
    end

    private

    attr_reader :post, :recipient

    def notify
      PushNotifications::ProcessorService.new(action: :followee_posted, notifiable: post, actor: post.user, recipient: recipient).call
    end
  end
end
