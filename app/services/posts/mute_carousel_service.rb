# frozen_string_literal: true

module Posts
  class MuteCarouselService
    def initialize(post_id:, user:, notifications_active:)
      @post_id = post_id
      @user = user
      @notifications_active = notifications_active
    end

    def call
      mute_carousel
    end

    private

    attr_reader :post_id, :user, :notifications_active

    def mute_carousel
      post = Post.active.find(post_id)

      raise ActionController::BadRequest, 'Post does not exist' unless post
      raise ActionController::BadRequest, 'Requested ID is not of the original post' unless post.original?

      conf = user.configuration

      if notifications_active.in?(['false', false])
        conf.carousel_notifications_blacklist << post_id
        conf.carousel_notifications_blacklist = conf.carousel_notifications_blacklist.uniq
      else
        conf.carousel_notifications_blacklist.delete(post_id)
      end

      conf.save!
    end
  end
end
