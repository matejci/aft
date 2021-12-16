# frozen_string_literal: true

module Api
  module V1
    class CommentsController < BaseController
      before_action :confirm_user_logged_in
      before_action :load_comment

      def upvote
        Upvote.toggle(@comment, @current_user)
        render partial: 'api/v1/votes/upvote', locals: { model_object: @comment }
      end

      private

      def load_comment
        @comment = Comment.active.find(params[:id])

        raise ActionController::BadRequest, 'Comment not found' unless @comment
      end
    end
  end
end
