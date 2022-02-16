# frozen_string_literal: true

module Api
  module V1
    class RoomsController < BaseController
      before_action :confirm_user_logged_in

      def create
        raise ActionController::BadRequest, 'Members param is required' if room_params[:members].blank?

        @room = Rooms::CreateService.new(name: room_params[:name], user: @current_user, members: room_params[:members]).call
      end

      def index
        @rooms = Rooms::IndexService.new(page: params[:page], user: @current_user).call
      end

      def show
        @collection = Rooms::DetailsService.new(room_id: params[:id]).call
      end

      def last_read_message
        Rooms::UpdateLastReadMessageService.new(room_id: params[:id], user_id: @current_user.id.to_s, message_id: params[:message_id]).call
        head :ok
      end

      private

      def room_params
        params.require(:room).permit(:name, :is_public, members: [])
      end
    end
  end
end
