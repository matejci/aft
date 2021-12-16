# frozen_string_literal: true

module Feeds
  class ExploreService < BaseService
    def initialize(user:, page_number:, feed_type:, categories: nil)
      @user = user
      @user_id = user.id.to_s if user.present?
      @page_number = page_number.presence || 1
      @feed_type = feed_type
      @categories_filter = categories.split(',') if categories.present?
    end

    def call
      explore_feed
    end

    private

    attr_reader :user, :user_id, :page_number, :feed_type, :categories_filter

    def explore_feed
      generate_explore_feed(prepare_data)
    end

    def generate_explore_feed(data)
      return { posts: [], total_pages: 0 } if data[0].blank?

      custom_posts = Posts::CarouselBuilderService.new(posts_data: data[0],
                                                       takkos_data: data.dig(1, :takkos),
                                                       users_data: data.dig(1, :users),
                                                       votes: data.dig(1, :votes),
                                                       viewer: user,
                                                       viewer_conf: data.dig(1, :viewer_conf),
                                                       parents_data: data.dig(1, :parents)).call

      { posts: custom_posts, total_pages: data[2], type: 'explore' }
    end

    def prepare_data
      query_options = default_query_options(page_number: page_number, per_page: PER_PAGE[:explore_feed])
      query_options[:where][:category_id.in] = categories_filter if categories_filter
      collection = Post.search('*', **query_options)
      total_pages = collection.total_pages
      collection = collection.to_a

      contest = Contest.active.first
      collection.prepend(contest.post) if contest

      data = Posts::CarouselDataService.new(collection: collection, viewer: user).call

      [collection, data, total_pages]
    end

    def explore_filters
      { view_public: true }
    end
  end
end
