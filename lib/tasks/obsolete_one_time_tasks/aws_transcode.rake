# frozen_string_literal: true

namespace :aws do
  desc 'Transcode media files'
  task transcode: :environment do
    OneTimeJobs::AwsTranscodeS3FilesJob.perform_later
  end
end
