# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  url = ENV.fetch('REDIS_URL', 'redis://localhost:6379')

  Sidekiq.configure_server do |config|
    config.redis = {
      url: url,
      size: Integer(ENV.fetch('SIDEKIQ_CONCURRENCY', 5)) + 10,
      network_timeout: 5
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: url,
      size: 2,
      network_timeout: 5
    }
  end
end
