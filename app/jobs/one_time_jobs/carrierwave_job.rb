# frozen_string_literal: true

module OneTimeJobs
  class CarrierwaveJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('Versions recreation started!')

      Post.all.no_timeout.each do |post|
        post.media_thumbnail.recreate_versions! if post.media_thumbnail.present?
      end

      Rails.logger.info('Versions recreation completed!')
    end
  end
end
