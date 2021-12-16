# frozen_string_literal: true

module Verifications
  class SendSmsService < SendService
    def call
      super { send_sms }
    end

    private

    attr_reader :phone

    def send_sms
      prepare_verification

      message = Twilio::REST::Client.new.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: verification.phone.delete('-'),
        body: "#{verification.code} is your App for teachers verification code"
      )

      verification.twilio_sids << message.sid
      verification.save!

      { success: true, message: "code sent to #{verification.phone}" }
    rescue Twilio::REST::RequestError => e
      Bugsnag.notify(e) { |report| report.add_tab(:verification, verification.attributes) }
      raise ServiceError, e
    end

    def prepare_verification
      verification.expires_at = 2.minutes.after
      super
    end
  end
end
