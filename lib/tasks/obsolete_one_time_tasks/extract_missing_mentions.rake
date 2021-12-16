# frozen_string_literal: true

namespace :extract do
  desc 'Extracting missing mentions'
  task missing_mentions: :environment do
    OneTimeJobs::ExtractMentionsJob.perform_later
  end
end
