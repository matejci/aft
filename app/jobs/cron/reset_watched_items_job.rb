# frozen_string_literal: true

module Cron
  class ResetWatchedItemsJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: 1

    def perform
      return unless Time.zone.today.monday?

      UserConfiguration.update_all(watched_items: [])
    end
  end
end
