# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default to: %w[admin@appforteachers.com matej@appforteachers.com],
          from: 'AFT <noreply@appforteachers.com>'

  def report_error
    @name = params[:name]
    @data = params[:data]
    mail(subject: "⚠️⚠️ TeachersErrorReporting: #{@name} occurred ⚠️⚠️")
  end
end
