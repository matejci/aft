# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /sessions' do
    it 'returns response with status code 302 and redirects if request is of HTML format' do
      web_app = create(:app, app_type: 'web')
      web_app.set(app_id: ENV['APP_ID']) # FactoryBot does not set proper app_id because of `App.init` method which is triggered on create.

      get sessions_path, headers: { 'User-Agent' => 'rspec', 'APP-ID' => ENV['APP_ID'] }
      expect(response).to have_http_status(:redirect)
    end

    it 'returns response with status code 200 if request is of JSON format' do
      app = create(:app)

      payload = {
        app_id: app.app_id,
        public_key: app.public_key
      }

      user_agent = 'rspec'
      token = JWT.encode(payload, app.secret + user_agent, 'HS512')

      get sessions_path(format: :json), headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('sessions')
    end
  end

  describe 'GET /login' do
    it 'returns response with status code 200 if request is of HTML format' do
      web_app = create(:app, app_type: 'web')
      web_app.set(app_id: ENV['APP_ID']) # FactoryBot does not set proper app_id because of `App.init` method which is triggered on create.

      get new_session_path, headers: { 'User-Agent' => 'rspec' }
      expect(response).to have_http_status(:ok)
    end

    it 'returns response with status code 400 and error message if request is of JSON format' do
      app = create(:app)

      payload = {
        app_id: app.app_id,
        public_key: app.public_key
      }

      user_agent = 'rspec'
      token = JWT.encode(payload, app.secret + user_agent, 'HS512')

      get new_session_path(format: :json), headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to include('error')
    end
  end

  describe 'POST /sessions' do
    it 'returns response with status code 201 if request is of JSON format' do
      user = create(:user)
      app = create(:app)

      login_params = {
        user: {
          id: user.email,
          password: '123456'
        }
      }

      payload = {
        app_id: app.app_id,
        public_key: app.public_key
      }

      user_agent = 'rspec'
      token = JWT.encode(payload, app.secret + user_agent, 'HS512')

      post sessions_path(format: :json), params: login_params, headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }

      expect(response).to have_http_status(:created)

      body = response.parsed_body
      expect(body).to include('id', 'email', 'phone', 'display_name', 'first_name', 'last_name', 'username', 'bio', 'profile_thumb_url',
                              'profile_image_version', 'background_image_url', 'background_image_version', 'access_token', 'verified', 'website',
                              'followers_count', 'followees_count', 'posts_count', 'takkos_count', 'valid_account', 'account_errors',
                              'monetization_status_type', 'creator_program_opted')
    end
  end

  describe 'GET /signout' do
    it 'returns response with status code 200 if request is of JSON format' do
      user = create(:user)
      app = create(:app)

      payload = {
        app_id: app.app_id,
        public_key: app.public_key
      }

      login_params = {
        user: {
          id: user.email,
          password: '123456'
        }
      }

      user_agent = 'rspec'
      token = JWT.encode(payload, app.secret + user_agent, 'HS512')

      post sessions_path(format: :json), params: login_params, headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }
      # TODO, check why get '/signout' doesn't work... using delete session_path, since both are mapped to same controller#action
      # get '/signout,json', headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }
      delete session_path(id: 'whatever', format: :json), headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('status' => 'signed out')
    end

    it 'returns response with status code 200 if request is of JSON format, and update session.live to false' do
      user = create(:user)
      app = create(:app)

      payload = {
        app_id: app.app_id,
        public_key: app.public_key
      }

      login_params = {
        user: {
          id: user.email,
          password: '123456'
        }
      }

      user_agent = 'rspec'
      token = JWT.encode(payload, app.secret + user_agent, 'HS512')

      post sessions_path(format: :json), params: login_params, headers: { 'User-Agent' => user_agent, 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }

      session = Session.last

      expect(session.live).to be true

      delete session_path(id: 'whatever', format: :json), headers: { 'User-Agent' => 'rspec',
                                                                     'APP-ID' => app.app_id,
                                                                     'HTTP-X-APP-TOKEN' => token,
                                                                     'HTTP-ACCESS-TOKEN' => session.token }

      expect(response).to have_http_status(:ok)

      session.reload
      expect(session.live).to be false
    end

    it 'redirects if request is of HTML format' do
      user = create(:user)
      app = create(:app)

      payload = {
        app_id: app.app_id,
        public_key: app.public_key
      }

      login_params = {
        user: {
          id: user.email,
          password: '123456'
        }
      }

      user_agent = 'rspec'
      token = JWT.encode(payload, app.secret + user_agent, 'HS512')

      post sessions_path(format: :json), params: login_params, headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }
      delete session_path(id: 'whatever'), headers: { 'User-Agent' => 'rspec', 'APP-ID' => app.app_id, 'HTTP-X-APP-TOKEN' => token }

      expect(response).to have_http_status(:redirect)
    end
  end
end
