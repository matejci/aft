# frozen_string_literal: true

module Cron
  class DeleteAccountsJob < ApplicationJob
    queue_as :cron_jobs
    sidekiq_options retry: 1

    def perform
      DeleteAccountsService.new.call
    end
  end
end
