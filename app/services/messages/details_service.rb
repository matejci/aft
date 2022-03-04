# frozen_string_literal: true

module Messages
  class DetailsService
    def initialize(room:, user:, message_id:)
      @room = room
      @user = user
      @message_id = message_id
    end

    def call
      validation
      message_details
    end

    private

    attr_reader :room, :user, :message_id

    def validation
      raise ActionController::BadRequest, 'Wrong message id' unless (@msg = room.messages.find(message_id))
      raise ActionController::BadRequest, "You're not a member of the room" unless room.member_ids.include?(user.id)
    end

    def message_details
      {
        id: @msg.id.to_s,
        content: @msg.content,
        message_type: @msg.message_type,
        room_id: @msg.room_id.to_s,
        sender_id: @msg.sender_id.to_s
      }
    end
  end
end
