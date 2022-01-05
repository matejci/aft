# frozen_string_literal: true

module Messages
  class CreateService
    def initialize(room:, content:, attachment:, user:)
      @room = room
      @content = content
      @attachment = attachment
      @user = user
    end

    def call
      create_message
    end

    private

    attr_reader :room, :content, :attachment, :user

    def create_message
      message = room.messages.create!(content: content, attachment: attachment, sender: user)

      ActionCable.server.broadcast("#{room.name}", content)

      message
    end
  end
end
