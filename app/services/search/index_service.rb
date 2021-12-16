# frozen_string_literal: true

module Search
  class IndexService < BaseService
    include TakkoStructs

    def initialize(query: nil, viewer: nil)
      @query = query
      @viewer = viewer
    end

    def call
      validate_search
      search
    end

    private

    attr_reader :query, :viewer

    def search
      # cache_key = generate_cache_key
      # cached_search = RedisCacheService.instance.get(key: cache_key)

      # return cached_response(JSON.parse(cached_search), cache_key) if cached_search

      # search_data = prepare_search_data

      # RedisCacheService.instance.set(key: cache_key, data: search_data.to_json)
      # RedisCacheService.instance.expire(key: cache_key, expire_in: CACHE_EXPIRATION[:search_index].minutes)

      # search_data

      prepare_search_data
    end

    def prepare_search_data
      threads = []
      search_results = {}

      threads << Thread.new { search_results[:posts] = Search::PostsService.new(query: query, viewer: viewer).call }
      threads << Thread.new { search_results[:users] = Search::UsersService.new(query: query, viewer: viewer).call }
      threads.each(&:join)

      search_results
    end
  end
end
