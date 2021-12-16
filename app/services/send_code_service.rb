# frozen_string_literal: true

class SendCodeService
  def initialize(user:, email: nil, phone: nil)
    @user = user
    @email = email
    @phone = phone
  end

  def call
    send_code
  end

  private

  attr_reader :user, :email, :phone

  def send_code
    verification = VerificationCheckService.new(user: user, email: email, phone: phone).call
    send_service = case verification.class
                   when EmailVerification
                     Verifications::SendEmailService
                   when PhoneVerification
                     Verifications::SendSmsService
    end

    send_service.new(verification: verification).call
  end
end
