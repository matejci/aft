# frozen_string_literal: true

class PasswordValidatorService
  include ServiceErrorHandling

  def initialize(user:)
    @user = user
  end

  def call
    super do
      raise ServiceError, 'nothing to validate' unless user.new_password || user.password

      password = prepare_password(user.new_password ? :new_password : :password)

      user.password_verification_token = nil if user.password_token # expire used token
      user.password_salt, user.password_hash = encrypt_password(password)

      { success: true }
    end
  end

  private

  attr_reader :user

  def encrypt_password(password)
    salt = BCrypt::Engine.generate_salt
    [salt, BCrypt::Engine.hash_secret(password, salt)]
  end

  def prepare_password(field)
    value = user.send(field)

    user.validates_presence_of field, message: 'Please choose a password'

    if value.present?
      user.validates_length_of field, minimum: 6, maximum: 64
      user.validates_confirmation_of field

      authenticate_request if field == :new_password && user.password_hash.present?
    end

    raise InstanceError, user.errors if (user.errors.keys & [field, :new_password_confirmation]).any?

    user.send("#{field}=", nil)
    value
  end

  def authenticate_request
    if user.password.blank? && user.password_token.blank?
      user.errors.add(:new_password, 'Please provide current password or reset password token')
    elsif user.password.present?
      user.authenticate(user.password)
    elsif user.password_token.present? && user.password_token != user.password_verification_token
      user.errors.add(:password_token, 'Incorrect token')
    end
  end
end
