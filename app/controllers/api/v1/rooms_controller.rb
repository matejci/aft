# frozen_string_literal: true

module Api
  module V1
    class RoomsController < BaseController
      before_action :confirm_user_logged_in

      def create
        raise ActionController::BadRequest, 'Members param is required' if room_params[:members].blank?

        members = room_params[:members]
        members << @current_user.id.to_s

        @room = Rooms::CreateService.new(name: room_params[:name], is_public: room_params[:is_public], members: members).call
      end

      def index
        @rooms = Rooms::IndexService.new(page: params[:page], user: @current_user).call
      end

      def show; end

      private

      def room_params
        params.require(:room).permit(:name, :is_public, members: [])
      end
    end
  end
end
