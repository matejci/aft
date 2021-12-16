# frozen_string_literal: true

class GeneratePasswordTokenService
  def initialize(user:)
    @user = user
  end

  def call
    generate_token
  end

  private

  attr_reader :user

  def generate_token
    token = unique_token

    user.set(password_verification_token: token)
    token
  end

  def unique_token
    loop do
      token = SecureRandom.urlsafe_base64
      break token unless User.where(password_verification_token: token).exists?
    end
  end
end
