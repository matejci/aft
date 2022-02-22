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

      Rooms::UpdateLastReadMessageService.new(room_id: nil, user_id: user.id, message_id: message.id.to_s, room: room).call

      msg = {
        id: message.id.to_s,
        content: message.content,
        message_type: message.message_type,
        room_id: message.room.id.to_s,
        sender_id: message.sender_id.to_s,
        created_at: message.created_at
      }

      ActionCable.server.broadcast(room.id.to_s, msg)
      send_notifications(room.id.to_s, msg[:sender_id], msg[:id])

      message
    end

    def validate_user
      raise ActionController::BadRequest, 'User is not a member of a room' unless room.member_ids.include?(user.id)
    end

    def send_notifications(room_id, sender_id, message_id)
      PushNotifications::DirectMessageNotificationsJob.perform_later(room_id: room_id, sender_id: sender_id, message_id: message_id)
    end
  end
end
