# frozen_string_literal: true

module Search
  class UsersService < BaseService
    include TakkoStructs

    def initialize(query: nil, viewer: nil, per_page: nil, page: nil)
      @query = query
      @viewer = viewer
      @per_page = per_page.presence || PER_PAGE[:search_index_users]
      @page = page.presence || 1
    end

    def call
      validate_search
      find_users
    end

    private

    attr_reader :query, :viewer, :per_page, :page

    def find_users
      users = User.search_for(query, viewer_id: viewer&.id&.to_s, per_page: per_page, page: page)

      { data: users, total_pages: users.total_pages }
    end
  end
end
