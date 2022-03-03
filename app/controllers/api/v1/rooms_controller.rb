# frozen_string_literal: true

module Api
  module V1
    class RoomsController < BaseController
      before_action :confirm_user_logged_in

      def create
        raise ActionController::BadRequest, 'Members param is required' if room_params[:members].blank?

        @collection = Rooms::CreateService.new(name: room_params[:name], user: @current_user, member_ids: room_params[:members]).call
        render :show
      end

      def index
        @collection = Rooms::IndexService.new(page: params[:page], user: @current_user).call
      end

      def show
        @collection = Rooms::DetailsService.new(room_id: params[:id]).call
      end

      def update
        @room = Rooms::UpdateService.new(room_id: params[:id], name: room_params[:name], user: @current_user).call
        render :add_members
      end

      def last_read_message
        Rooms::UpdateLastReadMessageService.new(room_id: params[:id], user_id: @current_user.id, message_id: params[:message_id]).call
        head :ok
      end

      def add_members
        raise ActionController::BadRequest, 'member_ids param needs to be an array' unless params[:member_ids].is_a?(Array)

        @room = Rooms::AddMembersService.new(room_id: params[:id], member_ids: params[:member_ids]).call
      end

      def leave_room
        Rooms::LeaveRoomService.new(room_id: params[:id], user: @current_user).call
        head :ok
      end

      def suggested_colleagues
        @collection = Rooms::SuggestedColleaguesService.new(user: @current_user).call
      end

      private

      def room_params
        params.require(:room).permit(:name, members: [])
      end
    end
  end
end
