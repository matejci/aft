# frozen_string_literal: true

module Api
  module V1
    class SharesController < BaseController
      before_action :confirm_user_logged_in

      def posts
        post = Post.active.find(params[:post_id])

        raise ActionController::BadRequest, 'Wrong post_id' unless post

        @current_user.shares.create!(post_id: params[:post_id])

        render json: { shares_count: post.reload.shares_count }, status: :created
      end
    end
  end
end
