# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Messages' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.appforteachers.v1'

  before do
    create_list(:user, 2)
    create(:room, created_by: user, member_ids: User.all.pluck(:id))
    create(:message, room_id: Room.last.id.to_s, sender_id: user.id.to_s)
  end

  route '/rooms/:room_id/messages.json', 'Create new message in chat room' do
    post 'Create message' do
      header 'Content-Type', 'application/json'

      with_options scope: :message do
        parameter :content, required: true
        parameter :message_type, required: true
      end

      parameter :room_id, required: true

      context '200' do
        let(:content) { 'How do you do?' }
        let(:message_type) { 'text' }
        let(:room_id) { Room.last.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data']).to include('id', 'content', 'message_type', 'payload_url')
        end
      end
    end
  end

  route '/rooms/:room_id/messages.json?page=1', 'Get paginated messages of particular chat room' do
    get 'Fetch messages' do
      parameter :room_id, required: true

      context '200' do
        let(:room_id) { Room.last.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data'].first).to include('id', 'content', 'sender_id', 'message_type', 'created_at', 'payload')
        end
      end
    end
  end
end
