# frozen_string_literal: true

namespace :carrierwave do
  desc 'Fetches S3 images, detect dimensions and updates Post model'
  task media_thumbnail_dimensions: :environment do
    OneTimeJobs::MediaThumbnailDimensionsJob.perform_later
  end
end
