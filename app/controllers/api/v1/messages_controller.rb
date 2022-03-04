# frozen_string_literal: true

module Api
  module V1
    class MessagesController < BaseController
      before_action :confirm_user_logged_in
      before_action :load_room

      def create
        @message = Messages::CreateService.new(room: @room,
                                               content: msg_params[:content],
                                               payload: msg_params[:payload],
                                               message_type: msg_params[:message_type],
                                               user: @current_user).call
      end

      def index
        @messages = Messages::IndexService.new(room: @room, page: params[:page], per_page: params[:per_page], user: @current_user).call
      end

      def show
        head :ok
        # msg = Messages::DetailsService.new(room: @room, message_id: params[:id], user: @current_user).call

        # render json: { data: msg }, status: :ok
      end

      private

      def load_room
        @room = Room.find(params[:room_id])

        raise ActionController::BadRequest, 'Wrong room_id, or room does not exist.' unless @room
      end

      def msg_params
        params.require(:message).permit(:content, :payload, :message_type)
      end
    end
  end
end
