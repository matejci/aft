# frozen_string_literal: true

class UserMailer < ApplicationMailer
  include SendGrid
  sendgrid_enable :opentrack

  default from: 'App For Teachers <noreply@appforteachers.com>'
  layout 'mailer'

  # waitlist confirmation
  def waitlist(subscriber)
    @subscriber = subscriber

    mail(to: subscriber.email, subject: "You're in line for App For Teachers!", from: 'App For Teachers <noreply@appforteachers.com>')
  end

  def reset_password
    @user = User.find(params[:user_id])
    mail(to: @user.email, subject: 'Reset App For Teachers Password', skip_premailer: true)
  end

  def files_download(user_id, email, link)
    send_to = email.presence || User.find(user_id).email
    @link = link

    mail(to: send_to, subject: 'Your App For Teachers files are ready!', skip_layout: true)
  end
end
