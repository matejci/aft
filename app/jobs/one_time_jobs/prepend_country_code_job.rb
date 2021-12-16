# frozen_string_literal: true

module OneTimeJobs
  class PrependCountryCodeJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('PrependCountryCodeJob started!')

      User.where(phone: /^(?!\+)\d{1,}/).no_timeout.each do |user|
        user.set(phone: "+1-#{user.phone}")
      end

      Rails.logger.info('Prepended country code to phone numbers!')
    end
  end
end
