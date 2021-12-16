# frozen_string_literal: true

Rails.application.config.after_initialize do
  # NOTE: This will work only if server is started by using `rails server` command.
  # e.g. if Puma is used with config `bundle exec puma -C config/puma.rb`, it won't work!
  AwsSubscription.subscribe! if defined?(Rails::Server)
end
