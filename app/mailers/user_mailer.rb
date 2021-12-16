# frozen_string_literal: true

class UserMailer < ApplicationMailer
  include SendGrid
  sendgrid_enable :opentrack

  default from: 'Takko <noreply@takko.app>'
  layout 'mailer'

  # waitlist confirmation
  def waitlist(subscriber)
    @subscriber = subscriber

    mail(to: subscriber.email, subject: "You're in line for Takko!", from: 'Takko <noreply@takko.app>')
  end

  def reset_password
    @user = User.find(params[:user_id])
    mail(to: @user.email, subject: 'Reset Takko Password', skip_premailer: true)
  end

  def files_download(user_id, email, link)
    send_to = email.presence || User.find(user_id).email
    @link = link

    mail(to: send_to, subject: 'Your Takko files are ready!', skip_layout: true)
  end
end
