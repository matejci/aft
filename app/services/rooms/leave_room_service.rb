# frozen_string_literal: true

module Rooms
  class LeaveRoomService
    def initialize(room_id:, user:)
      @room_id = room_id
      @user = user
      @room = nil
    end

    def call
      validate_user
      leave_room
    end

    private

    attr_reader :room_id, :user, :room

    def validate_user
      @room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless @room
      raise ActionController::BadRequest, "You're not member of this room" unless @room.member_ids.include?(user.id)
    end

    def leave_room
      room.members.delete(user)
      room.ex_members << user
      room.save!

      members = room.members.to_a

      return delete_room(room) if members.size == 1

      Rooms::MembersThumbService.new(room: room, members: members).call
      update_room_name(room, members)
      broadcast_member_left
    end

    def update_room_name(room, members)
      return if room.name.present?

      room.generated_name = members.pluck(:username).uniq.join(', ')
      room.save!
    end

    # This will delete room and all related messages
    def delete_room(room)
      room.destroy
    end

    def broadcast_member_left
      broadcast_data = {
        room: {
          id: room.id.to_s,
          name: room.name,
          generated_name: room.generated_name,
          created_by_id: room.created_by_id,
          created_at: room.created_at,
          updated_at: room.updated_at,
          last_read_messages: room.last_read_messages,
          members_count: room.members_count,
          room_thumb: room.room_thumb
        },
        member_left: {
          id: user.id.to_s,
          username: user.username,
          display_name: user.display_name,
          email: user.email,
          phone: user.phone,
          verified: user.verified,
          profile_thumb_url: user.profile_image.url,
          first_name: user.first_name,
          last_name: user.last_name
        }
      }

      WsBroadcastService.new(broadcaster: room_id, data: broadcast_data, type: 'UserLeft').call
    end
  end
end
