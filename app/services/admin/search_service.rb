# frozen_string_literal: true

module Admin
  class SearchService
    PER_PAGE = 5

    def initialize(query:, page: nil)
      @query_string = query
      @page = page.to_i < 1 ? 1 : page.to_i
    end

    def call
      search_posts
    end

    private

    attr_reader :query_string, :page

    def search_posts
      filters = { category_id: { not: Category.takko_tutorial_category._id.to_s } }

      query_options = {
        where: filters,
        order: { publish_date: { order: 'desc', unmapped_type: 'long' } },
        page: page,
        per_page: PER_PAGE
      }

      { posts: Post.search_for(query_string, query_options) }
    end
  end
end
