# frozen_string_literal: true

module OneTimeJobs
  class FollowCacheExpirerJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('FollowCacheExpirerJob started!')

      Rails.cache.delete_matched('*followers_ids')
      Rails.cache.delete_matched('*followees_ids')

      Rails.logger.info('followers/followees_ids cache expired!')
    end
  end
end
