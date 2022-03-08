# frozen_string_literal: true

module Cron
  class SmsAnnouncementJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: false

    def perform
      return unless Time.zone.today == Date.new(2022, 3, 9)

      phone_numbers = User.active.pluck(:phone).compact.uniq

      phone_numbers.each do |number|
        send_sms(number)
        sleep 2
      end
    end

    private

    def send_sms(number)
      message = Twilio::REST::Client.new.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: number.delete('-'),
        body: "App For Teachers now has group chats & DM's to help separate work messages from your personal lives! Please update to the latest version from the App Store!"
      )

      Bugsnag.notify(message.error_message) { |report| report.add_tab(:sms_announcement_error, number) } if message.error_code
    rescue Twilio::REST::RequestError => e
      Bugsnag.notify(e) { |report| report.add_tab(:sms_announcement_exception, number) }
    end
  end
end
