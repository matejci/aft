
# only run for staging and production environments
unless Rails.env.development? || Rails.env.test?
	Bugsnag.configure do |config|
	  config.api_key = ENV['BUGSNAG_API_KEY']

	  if ENV['HEROKU_ENV'] == 'staging'
	  	config.release_stage = 'staging'
	  elsif ENV['HEROKU_ENV'] == 'production'
	  	config.release_stage = 'production'
	  end
	end
end
