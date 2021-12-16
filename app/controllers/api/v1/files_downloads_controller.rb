# frozen_string_literal: true

module Api
  module V1
    class FilesDownloadsController < BaseController
      before_action :confirm_user_logged_in
      before_action :load_conf

      def prepare
        validate_email if params[:email].present?

        job = FilesDownloads::PrepareJob.perform_later(@current_user.id.to_s, params[:email])
        @conf.set(video_files: { sidekiq_job_id: job.job_id }) if @conf.video_files['sidekiq_job_id'].blank?

        render json: { message: 'Files download enqueued.' }, status: :ok
      end

      def download
        raise ActionController::BadRequest, 'Wrong identifier' if @conf.video_files['identifier'] != params[:identifier]

        render json: { download_link: @conf.video_files['download_link'] }, status: :ok
      end

      private

      def load_conf
        @conf = @current_user.configuration
      end

      def validate_email
        raise ActionController::BadRequest, 'Invalid email' if params[:email].match(EMAIL_REGEX).nil?
      end
    end
  end
end
