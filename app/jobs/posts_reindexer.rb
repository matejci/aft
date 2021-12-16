# frozen_string_literal: true

class PostsReindexer < ApplicationJob
  queue_as :post_reindex
  sidekiq_options retry: 3

  def perform(user_id:, event:)
    return unless (user = User.find(user_id))

    case event
    when :block
      # reindex user posts to reflect the blocked list change
      user.posts.reindex(:search_blocked_filter)
    when :follow
      # reindex followees posts to reflect the permitted list change
      Post.permission_set_by(user).reindex(:search_permitted_filter)
    when :username_change
      user.posts.reindex(:search_username)
    end
  end
end
