# frozen_string_literal: true

module Api
  module V1
    class SessionsController < BaseController
      before_action :confirm_user_logged_in

      def player_id
        UpdatePlayerIdService.new(token: request.headers['HTTP-ACCESS-TOKEN'], player_id: request.headers['PLAYER-ID']).call
        head :ok
      end
    end
  end
end
