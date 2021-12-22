# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::FilesDownloads' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.appforteachers.v1'

  before { create(:user_configuration, user: user) }

  route '/request-videos-download.json', 'Request video files to be downloaded' do
    get 'Request videos download link' do
      parameter :email

      context '200' do
        example_request '200' do
          expect(status).to eq(200)
          expect(JSON.parse(response_body)['message']).to eq('Files download enqueued.')
        end
      end

      context '400' do
        let(:email) { 'bla' }

        example_request '400' do
          expect(status).to eq(400)
          expect(JSON.parse(response_body)['error']).to eq('Invalid email')
        end
      end
    end
  end
end
