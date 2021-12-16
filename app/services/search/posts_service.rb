# frozen_string_literal: true

module Search
  class PostsService < BaseService
    include TakkoStructs

    def initialize(query: nil, viewer: nil, per_page: nil, page: nil)
      @query = query
      @viewer = viewer
      @per_page = per_page.presence || PER_PAGE[:search_index_posts]
      @page = page.presence || 1
    end

    def call
      validate_search
      posts
    end

    private

    attr_reader :query, :viewer, :per_page, :page

    def posts
      generate_posts(prepare_data)
    end

    def prepare_data
      collection = Post.search_for(query, viewer_id: viewer&.id&.to_s, per_page: per_page, page: page, includes: [:user, :category, :parent, :feed_item, :takkos])
      total_pages = collection.total_pages
      collection = collection.to_a

      data = Posts::CarouselDataService.new(collection: collection, viewer: viewer).call

      [collection, data, total_pages]
    end

    def generate_posts(data)
      return { data: [], total_pages: 0 } if data[0].blank?

      custom_posts = Posts::CarouselBuilderService.new(posts_data: data[0],
                                                       takkos_data: data.dig(1, :takkos),
                                                       users_data: data.dig(1, :users),
                                                       votes: data.dig(1, :votes),
                                                       viewer: viewer,
                                                       viewer_conf: data.dig(1, :viewer_conf),
                                                       parents_data: data.dig(1, :parents)).call
      { data: custom_posts, total_pages: data[2] }
    end
  end
end
