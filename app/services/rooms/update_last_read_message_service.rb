# frozen_string_literal: true

module Rooms
  class UpdateLastReadMessageService
    def initialize(room_id:, user_id:, message_id:)
      @room_id = room_id
      @user_id = user_id
      @message_id = message_id
    end

    def call
      update_read_message
    end

    private

    attr_reader :room_id, :user_id, :message_id

    def update_read_message
      room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless room

      room.last_read_messages[user_id] = message_id.to_s
      room.save!
    end
  end
end
