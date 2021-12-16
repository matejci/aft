# frozen_string_literal: true

# NOTE, be careful when making changes in this service. It is currently used across different API versions.
module Leaderboard
  class BaseService
    class LeaderboardError < StandardError; end

    VALID_QUERY_PARAM = %w[followed viewed takkos discussed upvoted].freeze
    ALLOWED_PERIODS = %w[all_time monthly weekly].freeze
    WEEKLY_PERIOD = Time.zone.today - 7.days
    MONTHLY_PERIOD = Time.zone.today - 30.days

    def initialize
      raise 'not implemented'
    end

    private

    def check_query
      raise LeaderboardError, 'Wrong query param' unless query.in?(VALID_QUERY_PARAM)
    end

    def check_period
      raise LeaderboardError, 'Wrong period param' unless period.in?(ALLOWED_PERIODS)
    end

    def takkos_match_query
      { parent_id: { '$ne' => nil }, active: true, own_takko: false, category_id: { '$ne' => Category.takko_tutorial_category.id }, view_permission: :public }
    end

    def sort_query
      { count: -1 }
    end

    def calculate_offset(per_page_key)
      return 0 if force_cache_expire

      (page.to_i - 1) * PER_PAGE[per_page_key]
    end

    def excluded_users_ids
      excluded_users_ids = excluded_users.pluck(:id)

      return excluded_users_ids unless viewer

      excluded_users_ids << viewer.block_user_ids
      excluded_users_ids.flatten.uniq
    end

    def excluded_users
      Rails.cache.fetch('takko_accounts') do
        User.active.where(:username.in => TAKKO_OFFICIAL_ACCOUNTS)
      end
    end

    def cache_key(type)
      "LB_#{type}_#{period}_#{query}_#{page}_#{viewer&.id}_#{force_cache_expire}"
    end

    def resolve_period
      period == 'weekly' ? WEEKLY_PERIOD : MONTHLY_PERIOD
    end
  end
end
