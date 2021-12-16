# frozen_string_literal: true

module OneTimeJobs
  class MediaThumbnailDimensionsJob < ApplicationJob
    queue_as :default

    def perform # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      Rails.logger.info('MediaThumbnailDimensionsJob started!')

      Post.where(media_thumbnail_dimensions: nil).no_timeout.each do |post|
        url = post&.media_thumbnail&.url
        next if url.blank?

        begin
          retries ||= 0
          image = MiniMagick::Image.open(url)
          post.set(media_thumbnail_dimensions: { width: image.dimensions[0], height: image.dimensions[1] })
        rescue StandardError => e
          Rails.logger.error("Error: #{e.message}; Retrying post: #{post._id}")
          retry if (retries += 1) < 3
        end
      end

      Rails.logger.info('Dimensions of media thumbnails updated!')
    end
  end
end
