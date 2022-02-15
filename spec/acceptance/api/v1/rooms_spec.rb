# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Rooms' do
  include_context 'authenticated request', user_session: true

  explanation <<~DOC
    - when creating new chat room, if `name` is not specified, BE will generate one by concatenating `usernames` of members
  DOC

  header 'X-API-VERSION', 'api.appforteachers.v1'

  before do
    create_list(:user, 3)
    create(:room, created_by: user, member_ids: User.all.pluck(:id))
    create(:message, room_id: Room.first.id, sender_id: user.id)
  end

  route '/rooms.json', 'Create new room/group chat' do
    post 'Create chat room' do
      with_options scope: :room do
        parameter :members, required: true
        parameter :name
      end

      context '200' do
        let(:members) { User.all.pluck(:id).map(&:to_s) }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data']).to include('id', 'name', 'created_by_id')
          expect(parsed_response['data']['name']).to eq(User.all.pluck(:username).join(' '))
        end
      end

      context '400' do
        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response).to include('error')
        end
      end
    end
  end

  route '/rooms.json?page=1', 'Get all rooms' do
    get 'Fetch all rooms' do
      context '200' do
        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data'].first).to include('id', 'name', 'created_by_id', 'created_at', 'updated_at')
        end
      end
    end
  end

  route '/rooms/:id.json', 'Get room details' do
    get 'Fetch chat room details' do
      context '200' do
        let(:id) { Room.first.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response.dig('data', 'room')).to include('id', 'name', 'created_by_id', 'created_at', 'updated_at', 'last_read_messages', 'members', 'messages')
        end
      end
    end
  end

  route '/rooms/:id/last-read-message.json', 'Update last read message for a user' do
    patch 'Update last read message' do
      parameter :message_id

      context '200' do
        let(:message_id) { Message.last.id.to_s }
        let(:id) { Room.last.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
        end
      end
    end
  end
end
