# frozen_string_literal: true

module OneTimeJobs
  class RemoveUnusedFeedJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('RemoveUnusedFeedJob started!')

      feed_ids = Feed.in(_type: %w[HomeFeed DiscoverFeed]).pluck(:id)
      Feed.in(id: feed_ids).set(_type: nil) # remove reserved `_type` first
      Feed.in(id: feed_ids).destroy_all

      Rails.logger.info('Removed no longer used home/discover feed!')
    end
  end
end
