# frozen_string_literal: true

module OneTimeJobs
  class ExtractPostHashtagsJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('ExtractPostHashtagsJob started!')

      takko_user = User.valid.find_by(username: 'takko')

      Post.active.no_timeout.each do |post|
        extract_hashtags(str: post.title, post: post, user: takko_user)
        extract_hashtags(str: post.description, post: post, user: takko_user)
      end

      Rails.logger.info('Finished extracting hashtags for posts!')
    end

    private

    def extract_hashtags(str:, post:, user:)
      Twitter::TwitterText::Extractor.extract_hashtags(str).each do |hashtag|
        tag = Hashtag.create_with(name: hashtag, created_by: user).find_or_create_by(link: hashtag.downcase.parameterize)

        tag.posts << post
      end
    end
  end
end
