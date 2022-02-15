# frozen_string_literal: true

# rubocop: disable Metrics/CyclomaticComplexity
module Leaderboard
  module V1
    class UsersService < BaseService
      include TakkoStructs

      def initialize(query:, viewer:, page: nil, period: nil, force_cache_expire: false)
        @query = query
        @page = page.presence || 1
        @viewer = viewer
        @period = period.presence || 'all_time'
        @force_cache_expire = force_cache_expire
        @per_page = force_cache_expire ? 50 : PER_PAGE[:lb_users]
      end

      def call
        check_query
        check_period
        send("most_#{query}")
      end

      private

      attr_reader :query, :page, :viewer, :period, :force_cache_expire, :per_page

      def generate_leaderboard(field)
        if period == 'all_time' && field != :takkos
          users = User.active.where.not(:id.in => excluded_users_ids).desc(field).limit(per_page)

          return users.pluck(:id) if force_cache_expire

          return prepare_users(users: users)
        end

        match_query = { created_at: { '$gte': resolve_period } }

        case field
        when :followers_count
          match_query[:followee_id] = { '$nin' => excluded_users_ids }
          group_query = { _id: '$followee_id', count: { '$sum': 1 } }
          model = 'Follow'
        when :counted_watchtime
          match_query[:user_id] = { '$nin' => excluded_users_ids }
          match_query[:counted] = true
          group_query = { _id: '$user_id', count: { '$sum': '$total' } }
          model = 'WatchTime'
        when :comments_count
          match_query.merge!({ user_id: { '$nin' => excluded_users_ids }, status: true, phantom: false })
          group_query = { _id: '$user_id', count: { '$sum': 1 } }
          model = 'Comment'
        when :takkos
          match_query = takkos_match_query.merge!(original_user_id: { '$nin' => excluded_users_ids })
          match_query[:publish_date] = { '$gte': resolve_period } if period != 'all_time'
          group_query = { _id: '$original_user_id', count: { '$sum': 1 } }
          model = 'Post'
        end

        aggregation = model.constantize.collection.aggregate([{ '$match': match_query },
                                                              { '$group': group_query },
                                                              { '$sort': sort_query },
                                                              { '$skip': calculate_offset(:lb_users) },
                                                              { '$limit': per_page }])

        return aggregation.pluck(:_id) if force_cache_expire

        users = User.active.find(aggregation.pluck(:_id))
        prepare_users(users: users, aggregation: aggregation, model: model)
      end

      # NOTE, cache code is repeating, but #generate_leaderboard needs to be wrapped in 'Rails.cache.fetch' block
      def most_followed
        Rails.cache.fetch(cache_key('users_most_followed'), force: force_cache_expire, expires_in: 1.hour) do
          generate_leaderboard(:followers_count)
        end
      end

      def most_viewed
        Rails.cache.fetch(cache_key('users_most_viewed'), force: force_cache_expire, expires_in: 1.hour) do
          generate_leaderboard(:counted_watchtime)
        end
      end

      def most_discussed
        Rails.cache.fetch(cache_key('users_most_discussed'), force: force_cache_expire, expires_in: 1.hour) do
          generate_leaderboard(:comments_count)
        end
      end

      def most_takkos
        Rails.cache.fetch(cache_key('users_most_takkos'), force: force_cache_expire, expires_in: 1.hour) do
          generate_leaderboard(:takkos)
        end
      end

      def prepare_users(users:, aggregation: nil, model: nil)
        return users_with_aggregation(users, aggregation, model) if aggregation

        users.each_with_object([]) do |user, users_response|
          users_response << create_custom_user(user)
        end
      end

      def users_with_aggregation(users, aggregation, model)
        aggregation.each_with_object([]) do |x, users_response|
          user = users.find { |u| u.id == x['_id'] }
          next unless user

          cu = create_custom_user(user)

          case model
          when 'Comment'
            cu.comments_count = x['count']
          when 'Post'
            cu.takkos_received = x['count']
          when 'Follow'
            cu.followers_count = x['count']
          when 'WatchTime'
            cu.counted_watchtime = x['count']
          end

          users_response << cu
        end
      end

      def create_custom_user(user)
        cu = CustomUser.new

        cu.id = user.id.to_s
        cu.email = user.email
        cu.phone = user.phone
        cu.display_name = user.display_name
        cu.first_name = user.first_name
        cu.last_name = user.last_name
        cu.username = user.username
        cu.profile_thumb_url = user.profile_thumb_url
        cu.followers_count = user.followers_count
        cu.verified = user.verified
        cu.counted_watchtime = user.counted_watchtime
        cu.comments_count = user.comments_count
        cu
      end
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity
