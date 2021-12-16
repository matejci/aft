# frozen_string_literal: true

module AwsSubscription
  def self.subscribe!
    return if Rails.env.in?(%w[test development])

    topic = ENV.fetch('AWS_TOPIC', 'arn:aws:sns:us-west-1:172370074799:transcoding_topic')

    sns = Aws::SNS::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                               secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                               region: 'us-west-1')

    sns.subscribe({ topic_arn: topic,
                    protocol: protocol,
                    endpoint: endpoint })

    Rails.logger.info("========== SUBSCRIBING TO AWS NOTIFICATIONS, TOPIC: #{topic} ==========")
  end

  def self.protocol
    return 'http' if Rails.env.development?

    'https'
  end

  def self.endpoint
    return 'http://deb60d4e8464.ngrok.io/notifications/aws' if Rails.env.development?

    ENV['AWS_SUBSCRIPTION_ENDPOINT']
  end
end
