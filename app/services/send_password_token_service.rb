# frozen_string_literal: true

class SendPasswordTokenService
  def initialize(email:)
    @errors = Hash.new { |h, k| h[k] = [] }
    @email = email
  end

  def call
    send_password_token
  end

  private

  attr_reader :errors, :email, :user

  def send_password_token
    return { success: false, errors: errors } unless valid?

    GeneratePasswordTokenService.new(user: user).call
    UserMailer.with(user_id: user.id.to_s).reset_password.deliver_later

    { success: true, email: email }
  end

  def valid?
    if email.blank?
      errors[:email] << "can't be blank"
    else
      @user = User.valid.find_by(email: email)
      errors[:email] << 'account not found' if user.nil?
    end

    errors.empty?
  end
end
