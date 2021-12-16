# frozen_string_literal: true

module FilesDownloads
  class RemoveJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: false

    def perform(key, config_id)
      @key = key
      @config_id = config_id
      @s3 = Aws::S3::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                region: 'us-west-1')

      remove_bucket_file
      clear_user_conf
    end

    private

    attr_reader :key, :config_id, :s3

    def remove_bucket_file
      s3.delete_objects({ bucket: ENV['USERS_ARCHIVES_BUCKET'], delete: { objects: [{ key: key }], quiet: false } })
    end

    def clear_user_conf
      conf = UserConfiguration.find(config_id)
      conf.video_files = {}
      conf.save!
    end
  end
end
