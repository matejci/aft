# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::UserConfiguration::Unmute/MuteCarouselNotitifications' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.takko.v1'

  explanation <<~DOC
    - turn on/off notifications for particular carousel by passing the ID of the original post
    - `notifications_active` param will be considered as true, unless it is a 'false' (string) or false (bool)
  DOC

  before { create(:user_configuration, user: user) }

  route '/user_configuration/mute_carousel/:post_id.json', 'turn off notifications for specific carousel/post' do
    patch 'mute carousel' do
      parameter :post_id, required: true
      parameter :notifications_active, required: true

      context '200' do
        let(:post_id) { create(:post, :public, user: user).id.to_s }
        let(:notifications_active) { false }

        example_request '200' do
          expect(status).to eq(200)
          expect(response_body).to be_empty
          expect(user.configuration.reload.carousel_notifications_blacklist).to include(post_id)
        end
      end
    end
  end

  route '/user_configuration/mute_carousel/:post_id.json', 'turn on notifications for specific carousel/post' do
    patch 'unmute carousel' do
      parameter :post_id, required: true
      parameter :notifications_active, required: true

      context '200' do
        let(:post_id) { create(:post, :public, user: user).id.to_s }
        let(:notifications_active) { true }

        example_request '200' do
          expect(status).to eq(200)
          expect(response_body).to be_empty
          expect(user.configuration.reload.carousel_notifications_blacklist).not_to include(post_id)
        end
      end
    end
  end
end
