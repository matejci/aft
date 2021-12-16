# frozen_string_literal: true

# NOTE: although this is not used anymore, I'm going to leave it here for now, might be useful
require 'singleton'

class RedisCacheService
  include Singleton

  def initialize
    @redis_cache = Redis.new(url: redis_url)
  end

  def get(key:)
    @redis_cache.get(key)
  end

  def set(key:, data:)
    @redis_cache.set(key, data)
  end

  def expire(key:, expire_in:)
    @redis_cache.expire(key, expire_in)
  end

  def delete_keys(pattern:)
    @redis_cache.scan_each(match: pattern).each do |key|
      @redis_cache.del(key)
    end
  end

  private

  def redis_url
    url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1/cache')
    url = "#{url}/1/cache" unless url.include?('/1/cache')
    url
  end
end
