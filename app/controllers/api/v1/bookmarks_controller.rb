# frozen_string_literal: true

module Api
  module V1
    class BookmarksController < BaseController
      before_action :confirm_user_logged_in
      before_action :set_config

      def index
        @collection = BookmarksIndexService.new(user: @current_user, bookmarks: @config.bookmarks, page: params[:page]).call
        render 'feed/feed_response'
      end

      def create
        post_id = params[:post_id]

        raise ActionController::BadRequest, 'post_id parameter is missing' if post_id.blank?
        render json: { error: 'Bookmark already exists' }, status: :unprocessable_entity and return if @config.bookmarks.include?(post_id)

        @config.bookmarks << post_id
        @config.save!

        head :ok
      end

      def destroy
        @config.bookmarks.delete(params[:post_id])
        @config.save!
        head :ok
      end

      private

      def set_config
        @config = @current_user.configuration
      end
    end
  end
end
