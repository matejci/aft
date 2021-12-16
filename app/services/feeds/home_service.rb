# frozen_string_literal: true

module Feeds
  class HomeService < BaseService
    def initialize(user:, page_number:, feed_type:)
      @user = user
      @user_id = user.id.to_s if user
      @page_number = page_number.presence || 1
      @feed_type = feed_type
    end

    def call
      return if user.blank?

      home_feed
    end

    private

    attr_reader :user, :user_id, :page_number, :feed_type

    def home_feed
      posts, total_pages = prepare_posts

      return if posts.blank?

      generate_home_feed(posts, total_pages)
    end

    def prepare_posts
      query_options = default_query_options(page_number: page_number, per_page: PER_PAGE[:home_feed])
      posts = Post.search('*', **query_options)
      total_pages = posts.total_pages

      [posts.to_a, total_pages]
    end

    def home_filters
      {
        _or: [
          { user_id: user_id }, # own
          { user_id: user.followees_ids.map(&:to_s) }.merge(permitted_filters) # followees
        ]
      }
    end

    def generate_home_feed(collection, total_pages)
      data = Posts::CarouselDataService.new(collection: collection, viewer: user).call
      custom_posts = Posts::CarouselBuilderService.new(posts_data: collection,
                                                       takkos_data: data[:takkos],
                                                       users_data: data[:users],
                                                       votes: data[:votes],
                                                       viewer: user,
                                                       viewer_conf: data[:viewer_conf],
                                                       parents_data: data[:parents]).call

      { posts: custom_posts, total_pages: total_pages, type: 'home' }
    end
  end
end
