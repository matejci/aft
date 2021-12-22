# frozen_string_literal: true

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :truncation

    Post.reindex
    User.reindex
    Hashtag.reindex

    Searchkick.disable_callbacks
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      App.first || App.create(
        name: 'test', email: 'test@email.com', app_type: 'ios', description: 'test', status: true
      ).tap do |app|
        # to override app#init
        app.set(app_id: ENV['APP_ID'], public_key: ENV['APP_PUBLIC_KEY'], secret: ENV['APP_SECRET'])
      end
      Category.create_with(name: 'Aft Tutorial').find_or_create_by(link: 'aft-tutorial')
      # Rails.cache.write('takko-user', create(:user, username: 'takko'))
      example.run
    end
  end

  config.around(:each, search: true) do |example|
    Searchkick.callbacks(nil) do
      example.run
    end
  end

  private

  def user_json(user)
    Jbuilder.new do |json|
      json.extract! user, :id, :username, :display_name, :profile_thumb_url, :profile_image_version, :verified
    end.attributes!
  end
end
