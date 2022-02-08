# frozen_string_literal: true

module Api
  module V1
    class UserConfigurationController < BaseController
      before_action :confirm_user_logged_in

      def notifications_settings
        render json: { data: @current_user.configuration.push_notifications_settings.except(:payout) }, status: :ok
      end

      def update_notifications_settings
        settings = PushNotifications::UpdateService.new(user: @current_user, params: push_notifications_params).call
        render json: { data: settings }, status: :ok
      end

      def mute_carousel
        Posts::MuteCarouselService.new(post_id: params[:post_id], user: @current_user, notifications_active: params[:notifications_active]).call
        head :ok
      end

      private

      def push_notifications_params
        params.require(:push_notifications_settings).permit(:upvoted, :added_takko, :commented, :mentioned, :followed, :payout, :followee_posted)
      end
    end
  end
end
