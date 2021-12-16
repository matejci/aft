# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  self.delivery_job = MailerJob
end
