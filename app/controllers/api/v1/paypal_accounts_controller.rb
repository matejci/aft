# frozen_string_literal: true

module Api
  module V1
    class PaypalAccountsController < BaseController
      before_action :confirm_user_logged_in

      def update
        paypal_account = @current_user.paypal_account

        if paypal_account.update(paypal_account_params)
          @current_user.monetization_status = true
          @current_user.monetization_status_type = :enabled
          @current_user.monetized_at = Time.current if @current_user.monetization_status_changed?
          @current_user.save(validate: false)

          render json: { email: paypal_account.email }, status: :ok
        else
          render json: paypal_account.errors, status: :unprocessable_entity
        end
      end

      private

      def paypal_account_params
        params.require(:paypal_account).permit(:email)
      end
    end
  end
end
