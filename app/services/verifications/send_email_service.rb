# frozen_string_literal: true

module Verifications
  class SendEmailService < SendService
    def call
      super { send_email }
    end

    private

    attr_reader :email

    def send_email
      prepare_verification

      VerificationMailer.with(verification_id: verification.id.to_s).send_code.deliver_now

      { success: true, message: "code sent to #{verification.email}" }
    end

    def prepare_verification
      verification.expires_at = 10.minutes.after
      super
    end
  end
end
