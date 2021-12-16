# frozen_string_literal: true

module Cron
  class CountViewsJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: 1

    def perform
      ViewCounter.run!
    end
  end
end
