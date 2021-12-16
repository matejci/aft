# frozen_string_literal: true

module PushNotifications
  class PnSenderJob < ApplicationJob
    queue_as :push_notifications
    sidekiq_options retry: 3

    def perform(notification_id:)
      @notification = Notification.find(notification_id)

      return unless notification

      @notifiable = notification.notifiable

      send_notification
    end

    private

    attr_reader :notification, :notifiable

    def send_notification
      Bugsnag.leave_breadcrumb("notification_id: #{notification.id}")

      OneSignalNotificationService.new(
        user: notification.recipient,
        ios_sound: 'takko.wav',
        headings: { en: notification.headings },
        contents: { en: notification.description },
        ios_attachments: { image_url: notification.image_url },
        data: { notifiable_url: notification.notifiable_url },
        collapse_id: collapse_id,
        ios_badgeCount: notification.recipient.unread_notifications_count,
        ios_badgeType: 'SetTo'
      ).call
    end

    def collapse_id
      notification.id.to_s if notification.upvoted?
    end
  end
end
