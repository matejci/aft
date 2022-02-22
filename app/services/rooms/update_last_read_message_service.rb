# frozen_string_literal: true

module Rooms
  class UpdateLastReadMessageService
    def initialize(room_id:, user_id:, message_id:, room: nil)
      @room_id = room_id
      @user_id = user_id
      @message_id = message_id
      @room = room
    end

    def call
      update_read_message
    end

    private

    attr_reader :room_id, :user_id, :message_id, :room

    def update_read_message
      chat_room = room.presence || Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless chat_room
      raise ActionController::BadRequest, "You're not a member of a room" unless chat_room.member_ids.include?(user_id)
      raise ActionController::BadRequest, 'message_id does not belong to a room' unless chat_room.message_ids.map(&:to_s).include?(message_id)

      chat_room.last_read_messages[user_id.to_s] = message_id
      chat_room.save!
    end
  end
end
