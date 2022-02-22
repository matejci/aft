# frozen_string_literal: true

module PushNotifications
  class DirectMessageNotificationsJob < ApplicationJob
    queue_as :push_notifications
    sidekiq_options retry: false

    def perform(room_id:, sender_id:, message_id:)
      @room = Room.includes(:members).find(room_id)
      return unless @room

      @sender = User.active.find(sender_id)
      return unless @sender

      @message_id = message_id

      notify
    end

    private

    attr_reader :room, :sender, :message_id

    def notify
      room.members.where.not(:id.in => [sender.id]).each do |member|
        PushNotifications::ProcessorService.new(action: :new_dm, notifiable: room, actor: sender, recipient: member, body: message_id).call
      end
    end
  end
end
