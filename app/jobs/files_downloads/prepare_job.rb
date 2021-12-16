# frozen_string_literal: true

require 'zip'

module FilesDownloads
  class PrepareJob < ApplicationJob
    queue_as :default
    sidekiq_options retry: false

    def perform(user_id, email)
      @user_id = user_id
      @email = email
      @conf = UserConfiguration.find_by(user_id: user_id)
      @s3 = Aws::S3::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                                region: 'us-west-1')

      check_job
      handle_files
    end

    private

    attr_reader :user_id, :email, :conf, :s3

    def check_job
      sidekiq_job_id = conf.video_files['sidekiq_job_id']
      return unless sidekiq_job_id

      raise 'Job is already scheduled!' if job_id != sidekiq_job_id
    end

    def handle_files
      folder_path = "#{Rails.root}/tmp/#{user_id}/" # rubocop: disable Rails/FilePath
      zip_name = "#{folder_path}#{user_id}_archive.zip"

      FileUtils.mkdir_p(folder_path)

      videos_urls = Post.active.where(user_id: user_id).map(&:media_file).map(&:path)

      files = []

      videos_urls.each do |video|
        file_name = "#{SecureRandom.urlsafe_base64}_#{video.split('/').last}"
        file_path = "#{folder_path}#{file_name}"

        File.open(file_path, 'wb') do |file|
          s3.get_object({ bucket: ENV['S3_BUCKET_NAME'], key: video }, target: file)
        end

        files << file_name
      rescue StandardError => _e
        FileUtils.remove_entry(file_path)
        next
      end

      generate_zip_file(zip_name, folder_path, files)
      s3_archive = upload_archive(zip_name)
      update_user_data(s3_archive.first)
      remove_files(files, folder_path, zip_name)
      notify_user(s3_archive.first)
      invoke_remove_archive_job(s3_archive.last)
    end

    def generate_zip_file(zip_name, folder_path, files)
      Zip::File.open(zip_name, Zip::File::CREATE) do |zipfile|
        files.each do |attachment|
          zipfile.add(attachment, File.join(folder_path, attachment))
        end
      end
    end

    def upload_archive(archive_file_path)
      key = archive_file_path.split('/').last
      bucket = ENV['USERS_ARCHIVES_BUCKET']

      File.open(archive_file_path, 'rb') do |file|
        s3.put_object({ bucket: bucket, key: key, body: file, acl: 'public-read' })
      end

      ["https://#{bucket}.s3.us-west-1.amazonaws.com/#{key}", key]
    end

    def update_user_data(download_link)
      conf.video_files[:download_link] = download_link
      conf.video_files[:expires_at] = Time.current + 5.hours
      conf.video_files[:identifier] = SecureRandom.urlsafe_base64
      conf.save!
    end

    def remove_files(files, folder_path, zip_name)
      files << zip_name.split('/').last
      files.each { |file| FileUtils.remove_entry("#{folder_path}#{file}") }
    end

    def notify_user(download_link)
      UserMailer.files_download(user_id, email, download_link).deliver_now
    end

    def invoke_remove_archive_job(key)
      FilesDownloads::RemoveJob.set(wait: 315.minutes).perform_later(key, conf.id.to_s)
    end
  end
end
