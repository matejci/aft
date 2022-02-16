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
      create_message
    end

    private

    attr_reader :room, :content, :payload, :message_type, :user

    def create_message
      message = room.messages.create!(content: content, payload: payload, message_type: message_type, sender: user)

      ActionCable.server.broadcast(room.id.to_s, content)

      message
    end
  end
end
