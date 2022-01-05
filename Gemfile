# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.2'

gem 'rails', '6.1.4'
gem 'jwt'

gem 'mongoid'
gem 'mongo'
gem 'mongoid-history'
gem 'mongoid-sadstory' # multi paramter fields support
gem 'mongoid-grid_fs'
gem 'mongo_session_store'

gem 'newrelic_rpm'
gem 'bson_ext'
gem 'kaminari-mongoid'
gem 'kaminari-actionview'

gem 'searchkick'
gem 'bcrypt'

gem 'twitter'
gem 'twitter-text'

gem 'mini_magick'

gem 'carrierwave', '~> 2.0'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'carrierwave-aws'
gem 'haml'

gem 'aws-sdk-s3'
gem 'aws-sdk-elastictranscoder'
gem 'aws-sdk-sns'

gem 'sidekiq'

gem 'rack-cors'

# mailer
gem 'sendgrid', '~> 1.2', '>= 1.2.4'
gem 'sendgrid-ruby'
gem 'premailer-rails'

# user agent parser and device detector
gem 'device_detector'

# twilio api for phone number verification and SMS
gem 'twilio-ruby', '~> 4.11', '>= 4.11.1'

gem 'bugsnag', '~> 6.13', '>= 6.13.1'

gem 'awesome_print'
gem 'pry-rails'

gem 'puma'
gem 'puma_worker_killer'
# gem 'rack-timeout' # TODO, uncomment once async uploads is implemented

gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'redis'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'rspec_api_documentation'
gem 'rubyzip'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 4.0.2'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false

  # ENV variables for development
  gem 'figaro'
end

group :development do
  gem 'meta_request' # chrome rails panel
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # foreman start -f Procfile.dev -p 3000
  # to launch --webpack=react
  gem 'foreman'
  gem 'letter_opener'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'database_cleaner', '1.8.5'
  gem 'mocha'
  gem 'capybara-email'
  gem 'launchy'
  gem 'faker'
end
