# frozen_string_literal: true

module Api
  module V1
    class InvitationsController < BaseController
      before_action :confirm_user_logged_in

      def phonebook_sync
        @collection = PhonebookSyncService.new(contacts: params[:contacts], viewer: @current_user).call

        render json: @collection, status: :ok
      end
    end
  end
end
