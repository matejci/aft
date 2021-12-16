# frozen_string_literal: true

module Search
  class BaseService
    class SearchParamMissing < StandardError; end
    class SearchParamTooShort < StandardError; end

    include TakkoStructs

    def initialize
      raise 'not implemented'
    end

    private

    def validate_search
      raise SearchParamMissing, 'Please provide search term' if query.blank?
      raise SearchParamTooShort, 'Please provide at least 3 chars for search term' if query.size < 3
    end

    def generate_cache_key
      case self.class.to_s
      when 'Search::IndexService'
        "index_search_for_#{query.tr(' ', '_')}_#{viewer&.id}"
      end
    end

    def cached_response(collection, cache_key)
      { posts: collection['posts'], users: collection['users'], cached: true, cache_key: cache_key }
    end
  end
end
