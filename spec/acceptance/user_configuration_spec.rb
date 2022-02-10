# frozen_string_literal: true

require 'acceptance_helper'

resource 'User Configuration' do
  include_context 'authenticated request', user_session: true

  explanation <<~EXPLANATION
    + `/user_configuration.json` will fallback to App's configuration if request is using `guest mode` (invalid `access_token`)
  EXPLANATION

  before do
    create(:user_configuration, user: user)
    app = create(:app)
    create(:configuration, app: app)
  end

  route '/user_configuration.json', 'get user config details' do
    get 'user config details' do
      context '200' do
        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response).to include('ads')
          expect(parsed_response['ads'].keys).to include('search_ads_enabled', 'search_ads_frequency', 'discover_ads_enabled', 'discover_ads_frequency')
        end
      end
    end
  end

  route '/user_configuration.json', 'app tracking transparency update' do
    patch "update users' app tracking transparency" do
      header 'Content-Type', 'application/json'

      with_options scope: :user_configuration do
        parameter :app_tracking_transparency, required: true
      end

      let(:raw_post) { params.to_json }

      context 'app tracking transparency' do
        let(:app_tracking_transparency) { 'undetermined' }

        example_request '200: correct app tracking transparency value' do
          expect(status).to eq(200)
        end
      end

      context 'app tracking transparency' do
        let(:app_tracking_transparency) { 'test' }

        example_request '400: wrong app tracking transparency value' do
          expect(status).to eq(400)
        end
      end
    end
  end

  route '/user_configuration.json', 'ads config update' do
    patch 'update ads settings' do
      header 'Content-Type', 'application/json'

      with_options scope: :user_configuration do
        parameter :ads, required: true
      end

      let(:ads) { { search_ads_enabled: true, search_ads_frequency: 10, discover_ads_enabled: true, discover_ads_frequency: 10, wrong_key: 'whatever' } }

      let(:raw_post) { params.to_json }

      context 'successful' do
        example_request '200' do
          expect(status).to eq(200)
          expect(user.configuration.ads.keys).not_to include(:wrong_key)
          expect(user.configuration.ads.keys).to include(:search_ads_enabled, :search_ads_frequency, :discover_ads_enabled, :discover_ads_frequency)
        end
      end
    end
  end
end
