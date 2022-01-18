# frozen_string_literal: true

module Aws
  class HlsVersionsDeleteService
    def initialize(bucket:, post_id:)
      @bucket = bucket
      @input_bucket_prefix = "media_file/#{post_id}"
    end

    def call
      clean_hls_versions
    rescue StandardError => e
      Rails.logger.error("HlsVersionsDeleteService ERROR: #{e.message}")
      raise e.message
    end

    private

    attr_reader :bucket, :input_bucket_prefix

    def clean_hls_versions
      s3 = Aws::S3::Client.new(connection_hash)
      list_objects = s3.list_objects_v2({ bucket: bucket, prefix: input_bucket_prefix })

      raise 'No S3 objects' if list_objects.blank?

      file_urls = list_objects.contents.map(&:key)

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

    def fetch_objects(s3_client, next_token)
      s3_client.list_objects_v2({ bucket: bucket, continuation_token: next_token, prefix: input_bucket_prefix })
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
