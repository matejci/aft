# frozen_string_literal: true

module CronJobs
  class << self
    def reset_watched_items!
      Cron::ResetWatchedItemsJob.perform_later
    end

    def delete_accounts!
      Cron::DeleteAccountsJob.perform_later
    end

    def process_payout!
      Cron::ProcessPayoutJob.perform_later
    end

    def count_views!
      Cron::CountViewsJob.perform_later
    end

    def process_pool!
      Cron::ProcessPoolJob.perform_later
    end

    def generate_badges!
      Cron::BadgesJob.perform_later
    end

    def send_sms_announcement!
      Cron::SmsAnnouncementJob.perform_later
    end
  end
end
