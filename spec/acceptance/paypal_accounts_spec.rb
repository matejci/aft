# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Paypal Account' do
  include_context 'authenticated request', user_session: true
  header 'X-API-VERSION', 'api.takko.v1'

  route '/paypal_account.json', 'paypal account' do
    patch 'update paypal account' do
      with_options scope: :paypal_account, required: true do
        parameter :email, 'email'
      end

      context '200' do
        let(:email) { user.email }

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response['email']).to eq user.email
        end
      end

      context '422' do
        let(:email) { nil }

        example_request '422' do
          expect(status).to eq 422
          expect(parsed_response['email']).to be_present
        end
      end
    end
  end
end
