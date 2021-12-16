# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default to: %w[admin@takkoapp.com k@takkoapp.com matej@takkoapp.com],
          from: 'Takko <noreply@takko.app>'

  def report_error
    @name = params[:name]
    @data = params[:data]
    mail(subject: "⚠️⚠️ TakkoErrorReporting: #{@name} occurred ⚠️⚠️")
  end
end
