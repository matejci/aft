# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Rooms' do
  include_context 'authenticated request', user_session: true

  explanation <<~DOC
    - When creating new chat room, if `name` param is not specified, BE will generate name by concatenating `usernames` of members.
    - In that case, response will return `generated_name` field, which should be used by the client.
    - In case `name` param is specified, `generated_name` will be null and client should use `name` field, as expected.
  DOC

  header 'X-API-VERSION', 'api.appforteachers.v1'

  before do
    create_list(:user, 3)
    create(:room, created_by: user, member_ids: User.all.pluck(:id))
    create(:message, room_id: Room.first.id, sender_id: user.id)
    create(:room, name: 'wrong room', created_by: User.last, member_ids: User.all.order(created_at: -1).take(2).pluck(:id))
    create(:message, room_id: Room.last.id, sender_id: user.id)
    create(:user)
  end

  route '/rooms.json', 'Create new room/group chat' do
    post 'Create chat room' do
      header 'Content-Type', 'application/json'

      with_options scope: :room do
        parameter :members, required: true
        parameter :name
      end

      context '200 - without name' do
        let(:members) { User.all.pluck(:id).map(&:to_s) }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data']).to include('id', 'name', 'generated_name', 'created_by_id', 'members_count', 'room_thumb')
          expect(parsed_response.dig('data', 'generated_name')).to eq(User.all.pluck(:username).join(', '))
          expect(parsed_response.dig('data', 'name')).to be_nil
        end
      end

      context '200 - with name' do
        let(:members) { User.all.pluck(:id).map(&:to_s) }
        let(:name) { 'test' }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data']).to include('id', 'name', 'generated_name', 'created_by_id', 'members_count', 'room_thumb')
          expect(parsed_response.dig('data', 'generated_name')).to be_nil
          expect(parsed_response.dig('data', 'name')).to eq('test')
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
          expect(parsed_response['data'].first).to include('id', 'name', 'generated_name', 'created_by_id', 'members_count', 'room_thumb', 'last_message')
        end
      end
    end
  end

  route '/rooms/:id.json', 'Get room details' do
    get 'Fetch chat room details' do
      parameter :id, required: true

      context '200' do
        let(:id) { Room.first.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response.dig('data', 'room')).to include('id', 'name', 'generated_name', 'created_by_id', 'created_at', 'updated_at',
                                                                 'last_read_messages', 'members', 'members_count', 'room_thumb', 'messages')
        end
      end
    end
  end

  route '/rooms/:id/last-read-message.json', 'Update last read message for a user' do
    patch 'Update last read message' do
      header 'Content-Type', 'application/json'
      parameter :id, required: true
      parameter :message_id

      context '200' do
        let(:message_id) { Message.first.id.to_s }
        let(:id) { Room.first.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
        end
      end

      context '400 - wrong message id' do
        let(:message_id) { 'some_id' }
        let(:id) { Room.first.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq('message_id does not belong to a room')
        end
      end

      context '400 - wrong room' do
        let(:message_id) { Message.last.id.to_s }
        let(:id) { 'some room id' }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq('Wrong room_id')
        end
      end

      context '400 - not a member of a room' do
        let(:message_id) { Message.last.id.to_s }
        let(:id) { Room.last.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq("You're not a member of a room")
        end
      end
    end
  end

  route '/rooms/:id/add-member.json', 'Add member to a chat room' do
    post 'Add new member' do
      header 'Content-Type', 'application/json'

      parameter :id, required: true
      parameter :member_id, required: true

      context '200 - without name' do
        let(:id) { Room.first.id.to_s }
        let(:member_id) { User.last.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data']).to include('id', 'name', 'generated_name', 'created_by_id', 'members_count', 'room_thumb')
        end
      end

      context '400' do
        let(:id) { Room.first.id.to_s }
        let(:member_id) { 'whatever' }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to include('Wrong member_id')
        end
      end
    end
  end

  route '/rooms/:id/leave-room.json', 'Leave the chat room' do
    delete 'Leave room' do
      header 'Content-Type', 'application/json'

      parameter :id, required: true

      context '200' do
        let(:id) { Room.first.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '200' do
          expect(status).to eq(200)
        end
      end

      context '400 - room does not exist' do
        let(:id) { 'some room_id' }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq('Wrong room_id')
        end
      end

      context '400 - user is not a member of a room' do
        let(:id) { Room.last.id.to_s }
        let(:raw_post) { params.to_json }

        example_request '400' do
          expect(status).to eq(400)
          expect(parsed_response['error']).to eq("You're not member of this room")
        end
      end
    end
  end

  route '/rooms/:id/suggested-colleagues.json', 'Fetch chat suggestions' do
    get 'Fetch suggested colleagues' do
      parameter :id, required: true

      context '200' do
        let(:id) { Room.first.id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['data'].first).to include('id', 'first_name', 'last_name', 'username', 'display_name', 'verified', 'email', 'phone', 'profile_thumb_url')
        end
      end
    end
  end
end
