# frozen_string_literal: true

module Api
  module V1
    class MessagesController < BaseController
      before_action :confirm_user_logged_in
      before_action :load_room

      def create
        @message = Messages::CreateService.new(room: @room, content: msg_params[:content], attachment: msg_params[:attachment], user: @current_user).call
      end

      def index
        @messages = Messages::IndexService.new(room: @room, page: params[:page], user: @current_user).call
      end

      private

      def load_room
        @room = Room.find(params[:room_id])

        raise ActionController::BadRequest, 'Wrong room_id, or room does not exist.' unless @room
      end

      def msg_params
        params.require(:message).permit(:content, :attachment)
      end
    end
  end
end
