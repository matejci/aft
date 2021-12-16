# frozen_string_literal: true

# This is used only via Rails console, to clean transcoded files, if needed
module Aws
  class CleanService
    def initialize(bucket: 'takko-prod-2020-12-08')
      @bucket = bucket
      @input_bucket_prefix = 'media_file'
    end

    def call
      clean_bucket
    rescue StandardError => e
      Rails.logger.error("CleanService ERROR: #{e.message}")
      raise e.message
    end

    private

    attr_reader :bucket, :input_bucket_prefix

    def clean_bucket
      s3 = Aws::S3::Client.new(connection_hash)
      list_objects = s3.list_objects_v2({ bucket: bucket, prefix: input_bucket_prefix })

      raise 'No S3 objects' if list_objects.blank?

      file_urls = list_objects.contents.map(&:key)
      next_token = list_objects.next_continuation_token

      loop do
        results = fetch_objects(s3, bucket, next_token)
        file_urls << results.contents.map(&:key)
        file_urls.flatten!
        next_token = results.next_continuation_token

        break unless results.is_truncated
      end

      urls_to_delete = parse_urls(file_urls)

      urls_to_delete.each do |url|
        s3.delete_object(bucket: bucket, key: url)
      end
    end

    def parse_urls(file_urls)
      urls = []

      file_urls.each do |url|
        next unless url.include?('.ts') || url.include?('.m3u8')

        urls << url
      end

      urls
    end

    def fetch_objects(s3_client, input_bucket, next_token)
      s3_client.list_objects_v2({ bucket: input_bucket, continuation_token: next_token, prefix: 'media_file' })
    end

    def connection_hash
      {
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: 'us-west-1'
      }
    end
  end
end
