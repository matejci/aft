# frozen_string_literal: true

class HlsVersionsCleanerJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 1

  def perform(post_id)
    Aws::HlsVersionsDeleteService.new(bucket: ENV.fetch('S3_BUCKET_NAME'), post_id: post_id).call
  end
end
