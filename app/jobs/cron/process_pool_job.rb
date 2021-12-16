# frozen_string_literal: true

module Cron
  class ProcessPoolJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: 1

    def perform
      ProcessPoolService.new.call
    end
  end
end
