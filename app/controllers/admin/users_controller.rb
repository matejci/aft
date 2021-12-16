# frozen_string_literal: true

module Admin
  class UsersController < ApplicationController
    before_action :confirm_admin_logged_in

    def verify
      return render json: { status: 'error', message: 'User not found' }, status: :not_found if user.blank?

      user.update!(verified: !user.verified)
      redirect_to admin_users_url
    end

    private

    def user
      @user ||= User.find(params[:id])
    end
  end
end
