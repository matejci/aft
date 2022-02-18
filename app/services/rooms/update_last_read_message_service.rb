# frozen_string_literal: true

module Rooms
  class UpdateLastReadMessageService
    def initialize(room_id:, user_id:, message_id:)
      @room_id = room_id
      @user_id = user_id
      @message_id = message_id
      @room = nil
    end

    def call
      update_read_message
    end

    private

    attr_reader :room_id, :user_id, :message_id

    def update_read_message
      room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless room
      raise ActionController::BadRequest, "You're not a member of a room" unless room.member_ids.include?(user_id)
      raise ActionController::BadRequest, 'message_id does not belong to a room' unless room.message_ids.map(&:to_s).include?(message_id)

      room.last_read_messages[user_id.to_s] = message_id
      room.save!
    end
  end
end
