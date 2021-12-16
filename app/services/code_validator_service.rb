# frozen_string_literal: true

class CodeValidatorService
  def initialize(user:, email_code: nil, phone_code: nil)
    @user = user
    @email_code = email_code
    @phone_code = phone_code
  end

  def call
    validate_code
  end

  private

  attr_reader :user, :email_code, :phone_code

  def validate_code
    verify_code(:email) if email_code
    verify_code(:phone) if phone_code
  end

  def verify_code(field)
    verification = user.send("#{field}_verification")
    code = send("#{field}_code")
    verified = Verifications::VerifyCodeService.new(verification: verification, code: code).call
    user.errors.add("#{field}_code", verified[:message]) unless verified[:success]
  end
end
