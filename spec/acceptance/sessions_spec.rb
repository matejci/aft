# frozen_string_literal: true

require 'acceptance_helper'

resource 'Sessions' do
  include_context 'authenticated request', user_session: true

  explanation <<~EXPLANATION
    + on /sessions.json
      + `creator_program_opted`: true == people who have attempted to sign up for creator program
      + `monetization_status_type`: enabled == people who are currently in the creator program receiving payments
  EXPLANATION

  route '/signout.json', 'user sign out' do
    get 'sign out' do
      before { expect(Session.last.live).to eq true }

      context '200' do
        example_request '200' do
          expect(status).to eq 200
          expect(Session.last.live).to eq false
        end
      end
    end
  end

  route '/sessions.json', 'user log in' do
    post 'log in' do
      before { header 'HTTP-ACCESS-TOKEN', nil }

      with_options scope: :user, required: true do
        parameter :id, 'email or phone'
        parameter :password, 'password'
      end

      context '201' do
        let(:id) { user.email }
        let(:password) { '123456' }

        example_request '201' do
          expect(status).to eq 201
          expect(parsed_response).to have_key 'creator_program_opted'
          expect(parsed_response).to have_key 'monetization_status_type'
        end
      end
    end
  end
end
