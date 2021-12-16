# frozen_string_literal: true

namespace :posts do
  desc 'Extract hashtags for posts'
  task extract_hashtags: :environment do
    OneTimeJobs::ExtractPostHashtagsJob.perform_later
  end
end
