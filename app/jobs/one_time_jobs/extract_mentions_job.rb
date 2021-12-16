# frozen_string_literal: true

module OneTimeJobs
  class ExtractMentionsJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('ExtractMentionsJob started!')

      Comment.active.no_timeout.each do |comment|
        usernames = Twitter::TwitterText::Extractor.extract_mentioned_screen_names(comment.text)

        usernames.each do |username|
          mentioned = User.valid.find_by(username: /^#{username}$/i)
          next unless mentioned && comment.mentions.where(user: mentioned).none?

          comment.mentions.create!(user: mentioned, mentioned_by: comment.user, body: comment.text)
        end
      end

      Rails.logger.info('Finished extracting missing mentions!')
    end
  end
end
