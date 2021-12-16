# frozen_string_literal: true

class VerificationMailer < ApplicationMailer
  default from: 'App for teachers admin <noreply@takko.app>'
  layout 'mailer'

  def send_code
    return unless (verification = Verification.find(params[:verification_id]))

    mail(
      to: verification.email,
      subject: 'App for teachers verification code',
      body: "#{verification.code} is your App for teachers verification code"
    )
  end
end
