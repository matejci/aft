# frozen_string_literal: true

class PoolIntervalLoadWatchtimesJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(pool_interval_id:)
    return unless (pool_interval = PoolInterval.find(pool_interval_id))

    pool_interval.load_watch_times
  end
end
