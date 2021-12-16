# frozen_string_literal: true

class VerificationCheckService
  def initialize(user:, email: nil, phone: nil)
    @user = user
    @email = email
    @phone = phone
  end

  def call
    verification_check
  end

  private

  attr_reader :user, :email, :phone

  def verification_check
    field = email.present? ? :email : :phone
    verification = user.send("#{field}_verification")

    if verification && verification.send(field) == send(field)
      verification
    else
      user.send("#{field}_verification=", nil) if verification # delete existing
      user.send("build_#{field}_verification", "#{field}": send(field))
    end
  end
end
