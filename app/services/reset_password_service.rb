# frozen_string_literal: true

class ResetPasswordService
  include ServiceErrorHandling

  def initialize(user:, params:)
    @user = user
    @password_token = params[:password_token] || ''
    @new_password = params[:new_password] || ''
    @new_password_confirmation = params[:new_password_confirmation]
  end

  def call
    super do
      raise ServiceError, 'missing user' if user.nil?

      return { success: true } if user.update(
        password_token: password_token,
        new_password: new_password,
        new_password_confirmation: new_password_confirmation
      )

      { success: false }
    end
  end

  private

  attr_reader :user, :password_token, :new_password, :new_password_confirmation
end
