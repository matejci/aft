# frozen_string_literal: true

module OneTimeJobs
  class CarrierwaveFilenameUpdateJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('CarrierwaveFilenameUpdateJob started!')

      User.any_of({ profile_image: nil }, { background_image: nil }).no_timeout.each do |user|
        next unless user.profile_image.present? || user.background_image.present?

        if user.profile_image.present?
          user.profile_image.send(:remove_versions!)
          user.profile_image.recreate_versions!
        end

        if user.background_image.present?
          user.background_image.send(:remove_versions!)
          user.background_image.recreate_versions!
        end

        user.save(validate: false)
      end

      Rails.logger.info('Filenames for profile/background images updated!')
    end
  end
end
