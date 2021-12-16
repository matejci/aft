# frozen_string_literal: true

module Aws
  class NotificationsProcessorService
    def initialize(data:)
      @data = JSON.parse(data)
    end

    def call
      process_notification
    end

    private

    attr_reader :data

    def process_notification
      case data['Type']
      when 'SubscriptionConfirmation'
        sns = Aws::SNS::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                   secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                   region: 'us-west-1')

        confirmation = sns.confirm_subscription({ topic_arn: data['TopicArn'], token: data['Token'] })

        if confirmation.successful?
          Rails.logger.info('========== AWS SubscriptionConfirmation COMPLETED ==========')
        else
          Rails.logger.error("========== AWS SubscriptionConfirmation Error #{confirmation.error} ==========")
        end
      when 'Notification'
        message = JSON.parse(data['Message'])
        Rails.logger.error("========== AWS Notification Error: #{message.dig('playlists', 0, 'statusDetail')} ==========") if message['state'] == 'ERROR'

        update_post_record(message)
      end
    end

    def update_post_record(message)
      post_id = message.dig('input', 'key').split('/')[1]
      Post.find(post_id)&.set(video_transcoded: true)
    end
  end
end
