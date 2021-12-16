# frozen_string_literal: true

module PushNotifications
  class CarouselDispatcherJob < ApplicationJob
    queue_as :push_notifications
    sidekiq_options retry: 2

    def perform(post_id:)
      @post = Post.includes(:parent).active.find(post_id)

      return unless @post

      notify_carousel_users
    end

    private

    attr_reader :post

    def notify_carousel_users
      user_ids = post.parent.takkos.pluck(:user_id)
      user_ids << post.original_user_id if post.original_user_id != post.user_id
      user_ids = user_ids.uniq
      user_ids -= [post.user_id]

      user_ids.each { |id| PushNotifications::CarouselJob.perform_later(post_id: post.id.to_s, recipient_id: id.to_s) }
    end
  end
end
