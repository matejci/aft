# frozen_string_literal: true

module Admin
  module BoostList
    class SearchService
      PER_PAGE = 10

      def initialize(query:, page: nil)
        @query = query
        @page = page.presence || 1
      end

      def call
        find_users
      end

      private

      attr_reader :query, :page

      def find_users
        { search_collection: User.search(query, page: page, per_page: PER_PAGE), boost_ids: IosConfigService.new.call.boost_list }
      end
    end
  end
end
