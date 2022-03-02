# frozen_string_literal: true

# TODO: this is a temp controller/endpoint that should be removed, once 'Auto-join' feature starts syncing room members via WebSockets
module Api
  module V1
    class UsersController < BaseController
      before_action :confirm_user_logged_in

      def show
        user = User.find(params[:id])

        raise ActionController::BadRequest, 'User not found' unless user

        render json: { data: user_data(user) }, status: :ok
      end

      private

      def user_data(user)
        {
          id: user.id.to_s,
          username: user.username,
          display_name: user.display_name,
          email: user.email,
          phone: user.phone,
          verified: user.verified,
          profile_thumb_url: user.profile_image.url(:thumb),
          first_name: user.first_name,
          last_name: user.last_name
        }
      end
    end
  end
end
