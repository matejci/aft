# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Messages' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.appforteachers.v1'

  before do
    create_list(:user, 3)
    create(:room, created_by: user, member_ids: User.all.pluck(:id))
    create(:message, room_id: Room.last.id.to_s, sender_id: user.id.to_s)
    room2 = create(:room, created_by: User.last, member_ids: User.where.not(id: User.first.id).pluck(:id))
    create(:message, room_id: room2.id.to_s, sender_id: User.last.id.to_s)
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
        let(:room_id) { Room.first.id.to_s }
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
        let(:room_id) { Room.first.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data'].first).to include('id', 'content', 'sender_id', 'message_type', 'created_at', 'payload')
        end
      end
    end
  end

  route '/rooms/:room_id/messages/:id.json', 'Get message details' do
    get 'Fetch message details' do
      parameter :room_id, required: true
      parameter :id, required: true

      context '200' do
        let(:room_id) { Room.first.id.to_s }
        let(:id) { Message.first.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data']).to include('id', 'sender_id', 'room_id', 'content', 'message_type')
        end
      end

      context '400' do
        let(:room_id) { Room.last.id.to_s }
        let(:id) { 'whatever' }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq('Wrong message id')
        end
      end

      context '400' do
        let(:room_id) { Room.last.id.to_s }
        let(:id) { Message.last.id.to_s }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq("You're not a member of the room")
        end
      end
    end
  end
end
