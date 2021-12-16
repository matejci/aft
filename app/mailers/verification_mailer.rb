# frozen_string_literal: true

class VerificationMailer < ApplicationMailer
  default from: 'App for teachers admin <noreply@appforteachers.com>'
  layout 'mailer'

  def send_code
    return unless (verification = Verification.find(params[:verification_id]))

    mail(
      to: verification.email,
      subject: 'App For Teachers verification code',
      body: "#{verification.code} is your App For Teachers verification code"
    )
  end
end
