# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::UserConfiguration::PushNotificationsSettings' do
  include_context 'authenticated request', user_session: true

  explanation <<~DOC
    - valid values for `upvoted`, `added_takko`, `commented` and `mentioned` attributes: `everyone`, `following`, `off`
    - valid values for `followed`, `payout` and `followee_posted` attributes: `on`, `off`
  DOC

  header 'X-API-VERSION', 'api.takko.v1'

  before { create(:user_configuration, user: user) }

  route '/user_configuration/push_notifications_settings.json', 'get user push notifications settings' do
    get "get user's push notifications settings" do
      context '200' do
        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response).to include('data')
          expect(parsed_response['data'].keys).to include('upvoted', 'added_takko', 'commented', 'mentioned', 'followed', 'payout', 'followee_posted')
        end
      end
    end
  end

  route '/user_configuration/push_notifications_settings.json', "update user's push notifications settings" do
    patch "update user's push notifications settings" do
      header 'Content-Type', 'application/json'

      with_options scope: :push_notifications_settings do
        parameter :upvoted
        parameter :added_takko
        parameter :commented
        parameter :mentioned
        parameter :followed
        parameter :payout
        parameter :followee_posted
      end

      context '200' do
        let(:upvoted) { 'following' }
        let(:added_takko) { 'off' }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response).to include('data')
          expect(parsed_response['data'].keys).to include('upvoted', 'added_takko', 'commented', 'mentioned', 'followed', 'payout', 'followee_posted')
          expect(parsed_response.dig('data', 'upvoted')).to eq('following')
          expect(parsed_response.dig('data', 'added_takko')).to eq('off')
        end
      end

      context '400' do
        let(:upvoted) { 'whatever' }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response).to include('error')
          expect(parsed_response['error']).to eq("Value 'whatever' not allowed for upvoted attribute. Allowed values: everyone, following, off")
        end
      end
    end
  end
end
