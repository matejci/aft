# frozen_string_literal: true

module Leaderboard
  module V1
    class PostsService < BaseService
      include TakkoStructs

      def initialize(query:, viewer:, page: nil, period: nil, force_cache_expire: false)
        @query = query
        @page = page.presence || 1
        @viewer = viewer
        @period = period.presence || 'all_time'
        @force_cache_expire = force_cache_expire
        @per_page = force_cache_expire ? 50 : PER_PAGE[:lb_posts]
      end

      def call
        check_query
        check_period
        send("most_#{query}")
      end

      private

      attr_reader :query, :page, :viewer, :period, :force_cache_expire, :per_page

      def most_viewed
        Rails.cache.fetch(cache_key('posts'), force: force_cache_expire, expires_in: 1.hour) do
          posts_leaderboard(:counted_watchtime)
        end
      end

      def most_discussed
        Rails.cache.fetch(cache_key('posts'), force: force_cache_expire, expires_in: 1.hour) do
          posts_leaderboard(:comments_count)
        end
      end

      def most_upvoted
        Rails.cache.fetch(cache_key('posts'), force: force_cache_expire, expires_in: 1.hour) do
          posts_leaderboard(:upvotes_count)
        end
      end

      def posts_leaderboard(order_field)
        posts = Post.active.without_tutorials.includes(:user, :category, :feed_item, :takkos, :parent).where.not(:user_id.in => excluded_users_ids)
        posts = posts.where(view_permission: :public)
        posts = posts.where(:publish_date.gte => resolve_period) if period != 'all_time'
        posts = posts.desc(order_field).page(page).per(per_page)

        return posts.pluck(:user_id) if force_cache_expire

        total_pages = posts.total_pages
        generate_posts(posts.to_a, total_pages)
      end

      def most_takkos
        Rails.cache.fetch(cache_key('posts'), force: force_cache_expire, expires_in: 1.hour) do
          prepare_takkos
        end
      end

      def prepare_takkos
        grouping_query = { _id: '$parent_id', count: { '$sum': 1 } }
        match_query = takkos_match_query.merge!(original_user_id: { '$nin' => excluded_users_ids })
        match_query[:publish_date] = { '$gte': resolve_period } if period != 'all_time'

        aggregation = Post.collection.aggregate([{ '$match': match_query },
                                                 { '$group': grouping_query },
                                                 { '$sort': sort_query },
                                                 { '$skip': calculate_offset(:lb_posts) },
                                                 { '$limit': per_page }])

        return Post.where(:_id.in => aggregation.pluck(:_id)).pluck(:user_id) if force_cache_expire

        # this does not return posts sorted by most takkos
        posts = Post.includes(:user, :category, :feed_item, :takkos, :parent).where(:_id.in => aggregation.pluck(:_id)).to_a

        collection = []

        # we need to loop through already sortered aggregation results in order to sort out collection by most takkos received
        aggregation.each do |agg_item|
          post = posts.find { |item| item.id == agg_item['_id'] }
          post.takkos_received = agg_item['count']
          collection << post
        end

        generate_posts(collection, calculate_total_pages(match_query))
      end

      def calculate_total_pages(match_query)
        total_posts = Post.where(match_query).count
        total_pages = total_posts / per_page

        (total_posts % per_page).zero? ? total_pages : total_pages + 1
      end

      def generate_posts(collection, total_pages)
        data = Posts::CarouselDataService.new(collection: collection, viewer: viewer).call
        custom_posts = Posts::CarouselBuilderService.new(posts_data: collection,
                                                         takkos_data: data[:takkos],
                                                         users_data: data[:users],
                                                         votes: data[:votes],
                                                         viewer: viewer,
                                                         viewer_conf: data[:viewer_conf],
                                                         parents_data: data[:parents]).call

        { posts: custom_posts, total_pages: total_pages, type: "leaderboard_posts_#{query}" }
      end
    end
  end
end
