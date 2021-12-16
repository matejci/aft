# frozen_string_literal: true

class ResetPasswordController < ApplicationController
  skip_before_action :set_current_user

  before_action :set_user, only: %i[new create]

  def new
    respond_to :html
  end

  def create
    reset_password = ResetPasswordService.new(user: @user, params: reset_params).call

    respond_to do |format|
      if reset_password[:success]
        format.html { render :success }
        format.json { render json: { status: 'success', message: 'password has been reset' } }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def reset_link
    redirect_to new_reset_password_path(user: { password_token: params[:token] })
  end

  def send_email
    respond_to :json

    send_token = SendPasswordTokenService.new(email: params[:email]).call

    if send_token[:success]
      render json: { success: "email sent to #{send_token[:email]}" }, status: :created
    else
      render json: send_token[:errors], status: :unprocessable_entity
    end
  end

  private

  def reset_params
    params.require(:user).permit(:password_token, :new_password, :new_password_confirmation)
  end

  def set_user
    password_token = reset_params[:password_token]
    @user = User.find_by(password_verification_token: password_token) if password_token.present?

    return unless @user.nil?

    if request.format.html?
      render :invalid_token
    else
      render json: { status: 'error', message: 'invalid token' }, status: :unprocessable_entity
    end
  end
end
