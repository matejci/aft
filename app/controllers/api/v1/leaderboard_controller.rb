# frozen_string_literal: true

module Api
  module V1
    class LeaderboardController < BaseController
      def posts
        @collection = Leaderboard::V1::PostsService.new(**prepare_params).call
      end

      def users
        @collection = Leaderboard::V1::UsersService.new(**prepare_params).call
      end

      private

      def prepare_params
        leaderboard_params.to_h.symbolize_keys.merge!(viewer: @current_user)
      end

      def leaderboard_params
        params.permit(:query, :page, :period)
      end
    end
  end
end
