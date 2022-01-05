# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require "active_record/railtie"
# require "active_storage/engine"
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AppForTeachers
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.action_controller.asset_host = ENV['URL_BASE']
    config.action_mailer.asset_host = ENV['URL_BASE']
    config.action_mailer.preview_path = Rails.root.join('test/mailers/previews')

    config.active_job.queue_adapter = :sidekiq

    config.autoload_paths += Dir[Rails.root.join('app/models/feed')]
    config.autoload_paths += Dir[Rails.root.join('app/models/verifications')]
    config.autoload_paths += Dir[Rails.root.join('app/queries')]
    config.autoload_paths += Dir[Rails.root.join('app/validators')]
    config.autoload_paths << config.root.join('lib')

    config.action_cable.disable_request_forgery_protection = true
  end
end
