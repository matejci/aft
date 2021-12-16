# frozen_string_literal: true

module Posts
  class CreatePostService
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      create_post
    end

    private

    attr_reader :user, :params

    def create_post
      post = user.posts.new(params)
      load_group_permissions(post)

      if post.save
        transcode_media_file(post)
        handle_push_notifications(post)
        boost_post_watchtime(post.id.to_s)
      end

      post
    end

    def load_group_permissions(post)
      %i[takko view].each do |action|
        next unless post.send("#{action}_permission") == :custom && (group_ids = post.send("#{action}er_group_ids"))

        user.user_groups.in(id: group_ids).each do |group|
          post.send("#{action}er_ids=", (post.send("#{action}er_ids") || []) | group.user_ids.map(&:to_s))
        end
      end
    end

    def transcode_media_file(post)
      return if Rails.env.development?

      Aws::TranscodeService.new(file: post.media_file.path).call
    end

    def handle_push_notifications(post)
      return if post.view_permission == :private

      PushNotifications::CarouselDispatcherJob.perform_later(post_id: post.id.to_s) if post.takko?
      PushNotifications::FollowersDispatcherJob.perform_later(post_id: post.id.to_s)
    end

    def boost_post_watchtime(post_id)
      conf = IosConfigService.new.call

      return if conf.post_boost['boost_value'].to_s == '1.0' || conf.post_boost['expires_at'] < Time.current

      conf.post_boost['post_ids'] << post_id
      conf.save!
    end
  end
end
