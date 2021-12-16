# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Invitations' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.takko.v1'

  parameter :contacts, required: true

  route '/invitations/phonebook-sync.json', 'Sync phonebook with currently following users' do
    post 'Sync phonebook' do
      context '200' do
        before do
          create_users
        end

        let(:contacts) { contacts_req_body }

        example_request '200' do
          expect(status).to eq(200)

          parsed_response = JSON.parse(response_body)

          expect(parsed_response.size).to eq(contacts_req_body.size)
          expect(parsed_response[0].keys).to include('uuid', 'username', 'already_following')
          expect(parsed_response[0]['already_following']).to eq(true)
          expect(parsed_response[1]['already_following']).to eq(true)
          expect(parsed_response[2]['already_following']).to eq(false)
          expect(parsed_response[3]['username']).to be_nil
        end
      end

      context '400' do
        let(:contacts) { '' }

        example_request '400' do
          expect(status).to eq(400)
          expect(JSON.parse(response_body)['error']).to eq('Contacts param is missing')
        end
      end
    end
  end

  def create_users
    u1 = create(:user, email: 'matej@takkoapp.com')
    u2 = create(:user, phone: '+1-123456789')
    create(:user, email: 'user@isp.net')

    user.follow!(u1)
    user.follow!(u2)
  end

  def contacts_req_body
    [
      {
        uuid: 'a_123456789',
        emails: ['matej@takkoapp.com'],
        phones: nil
      },
      {
        uuid: 'b_123456789',
        emails: nil,
        phones: ['123456789']
      },
      {
        uuid: 'c_123456789',
        emails: ['user@isp.net'],
        phones: ['1123123']
      },
      {
        uuid: 'd_123456789',
        emails: ['user2@isp.net'],
        phones: ['11231223']
      }
    ]
  end
end
