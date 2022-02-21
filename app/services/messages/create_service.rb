# frozen_string_literal: true

module Messages
  class CreateService
    def initialize(room:, content:, payload:, message_type:, user:)
      @room = room
      @content = content
      @payload = payload
      @message_type = message_type
      @user = user
    end

    def call
      validate_user
      create_message
    end

    private

    attr_reader :room, :content, :payload, :message_type, :user

    def create_message
      message = room.messages.create!(content: content, payload: payload, message_type: message_type, sender: user)
      room.set(last_message_id: message.id)

      ActionCable.server.broadcast(room.id.to_s, content)
      message
    end

    def validate_user
      raise ActionController::BadRequest, 'User is not a member of a room' unless room.member_ids.include?(user.id)
    end
  end
end
