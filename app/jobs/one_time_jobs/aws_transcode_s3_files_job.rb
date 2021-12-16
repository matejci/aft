# frozen_string_literal: true

module OneTimeJobs
  class AwsTranscodeS3FilesJob < ApplicationJob
    queue_as :default

    def perform
      Aws::TranscodeS3FilesService.new.call
    end
  end
end
