# frozen_string_literal: true

# rubocop: disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
module Cron
  class BadgesJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: 1

    def perform
      generate_badges
    end

    private

    def generate_badges
      users_hash = prepare_users_data
      users_from_posts_hash = prepare_posts_data
      update_configs(combine_hashes(users_hash, users_from_posts_hash))
    end

    def prepare_users_data
      user_ids = []
      users_badges_hash = Hash.new { |h, k| h[k] = [] }

      user_ids << all_time_users_by_views = Leaderboard::V1::UsersService.new(query: 'viewed', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_users_by_views = Leaderboard::V1::UsersService.new(query: 'viewed', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_users_by_views = Leaderboard::V1::UsersService.new(query: 'viewed', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids << all_time_users_by_takkos = Leaderboard::V1::UsersService.new(query: 'takkos', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_users_by_takkos = Leaderboard::V1::UsersService.new(query: 'takkos', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_users_by_takkos = Leaderboard::V1::UsersService.new(query: 'takkos', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids << all_time_users_by_followers = Leaderboard::V1::UsersService.new(query: 'followed', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_users_by_followers = Leaderboard::V1::UsersService.new(query: 'followed', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_users_by_followers = Leaderboard::V1::UsersService.new(query: 'followed', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids << all_time_users_by_comments = Leaderboard::V1::UsersService.new(query: 'discussed', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_users_by_comments = Leaderboard::V1::UsersService.new(query: 'discussed', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_users_by_comments = Leaderboard::V1::UsersService.new(query: 'discussed', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids.flatten.uniq.each do |id|
        badges = []
        badges << 'All time top creator by views' if all_time_users_by_views.include?(id)
        badges << 'Monthly top creator by views' if monthly_users_by_views.include?(id)
        badges << 'Weekly top creator by views' if weekly_users_by_views.include?(id)

        badges << 'All time top creator by takkos' if all_time_users_by_takkos.include?(id)
        badges << 'Monthly top creator by takkos' if monthly_users_by_takkos.include?(id)
        badges << 'Weekly top creator by takkos' if weekly_users_by_takkos.include?(id)

        badges << 'All time top creator by followers' if all_time_users_by_followers.include?(id)
        badges << 'Monthly top creator by followers' if monthly_users_by_followers.include?(id)
        badges << 'Weekly top creator by followers' if weekly_users_by_followers.include?(id)

        badges << 'All time top creator by comments' if all_time_users_by_comments.include?(id)
        badges << 'Monthly top creator by comments' if monthly_users_by_comments.include?(id)
        badges << 'Weekly top creator by comments' if weekly_users_by_comments.include?(id)

        users_badges_hash[id.to_s] = badges
      end

      users_badges_hash
    end

    def prepare_posts_data
      user_ids = []
      users_badges_hash = Hash.new { |h, k| h[k] = [] }

      user_ids << all_time_post_by_views = Leaderboard::V1::PostsService.new(query: 'viewed', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_post_by_views = Leaderboard::V1::PostsService.new(query: 'viewed', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_post_by_views = Leaderboard::V1::PostsService.new(query: 'viewed', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids << all_time_post_by_comments = Leaderboard::V1::PostsService.new(query: 'discussed', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_post_by_comments = Leaderboard::V1::PostsService.new(query: 'discussed', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_post_by_comments = Leaderboard::V1::PostsService.new(query: 'discussed', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids << all_time_post_by_upvotes = Leaderboard::V1::PostsService.new(query: 'upvoted', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_post_by_upvotes = Leaderboard::V1::PostsService.new(query: 'upvoted', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_post_by_upvotes = Leaderboard::V1::PostsService.new(query: 'upvoted', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids << all_time_post_by_takkos = Leaderboard::V1::PostsService.new(query: 'takkos', viewer: nil, period: 'all_time', force_cache_expire: true).call
      user_ids << monthly_post_by_takkos = Leaderboard::V1::PostsService.new(query: 'takkos', viewer: nil, period: 'monthly', force_cache_expire: true).call
      user_ids << weekly_post_by_takkos = Leaderboard::V1::PostsService.new(query: 'takkos', viewer: nil, period: 'weekly', force_cache_expire: true).call

      user_ids.flatten.uniq.each do |id|
        badges = []
        badges << 'All time top post by views' if all_time_post_by_views.include?(id)
        badges << 'Monthly top post by views' if monthly_post_by_views.include?(id)
        badges << 'Weekly top post by views' if weekly_post_by_views.include?(id)

        badges << 'All time top post by takkos' if all_time_post_by_takkos.include?(id)
        badges << 'Monthly top post by takkos' if monthly_post_by_takkos.include?(id)
        badges << 'Weekly top post by takkos' if weekly_post_by_takkos.include?(id)

        badges << 'All time top post by upvotes' if all_time_post_by_upvotes.include?(id)
        badges << 'Monthly top post by upvotes' if monthly_post_by_upvotes.include?(id)
        badges << 'Weekly top post by followers' if weekly_post_by_upvotes.include?(id)

        badges << 'All time top post by comments' if all_time_post_by_comments.include?(id)
        badges << 'Monthly top post by comments' if monthly_post_by_comments.include?(id)
        badges << 'Weekly top post by comments' if weekly_post_by_comments.include?(id)

        users_badges_hash[id.to_s] = badges
      end

      users_badges_hash
    end

    def combine_hashes(users, posts)
      posts.each do |key, val|
        if users.key?(key)
          users[key] << val
          users[key] = users[key].flatten
        else
          users[key] = val
        end
      end

      users
    end

    def update_configs(users_hash)
      UserConfiguration.update_all(badges: [])

      UserConfiguration.no_timeout.where(:user_id.in => users_hash.keys).each do |conf|
        conf.set(badges: users_hash[conf.user_id.to_s])
      end
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
