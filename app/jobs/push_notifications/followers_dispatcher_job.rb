# frozen_string_literal: true

module PushNotifications
  class FollowersDispatcherJob < ApplicationJob
    queue_as :push_notifications
    sidekiq_options retry: 2

    def perform(post_id:)
      @post_id = post_id

      notify_followers
    end

    private

    attr_reader :post_id

    def notify_followers
      post = Post.active.includes(:user).find(post_id)

      return unless post

      post.user.followers_ids.each { |id| PushNotifications::FollowerJob.perform_later(post_id: post_id, recipient_id: id.to_s) }
    end
  end
end
