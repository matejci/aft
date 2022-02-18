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
      room.member_ids.delete(user.id)
      room.save

      members = room.members.to_a

      return delete_room(room) if members.size == 1

      Rooms::MembersThumbService.new(room: room, members: members).call
      update_room_name(room, members)
    end

    def update_room_name(room, members)
      return if room.name.present?

      room.generated_name = members.pluck(:username).uniq.join(', ')
      room.save
    end

    # This will delete room and all related messages
    def delete_room(room)
      room.destroy
    end
  end
end
