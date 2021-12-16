# frozen_string_literal: true

module Cron
  class ProcessPayoutJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: 1

    def perform
      PayoutProcessor.new.call
    end
  end
end
