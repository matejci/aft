# frozen_string_literal: true

module Verifications
  class VerifyCodeService
    include ServiceErrorHandling

    def initialize(verification: nil, user: nil, email: nil, phone: nil, code: nil)
      @verification = verification
      @verification ||= VerificationCheckService.new(user: user, email: email, phone: phone).call
      @code = code
    end

    def call
      super { verify_code }
    end

    private

    attr_reader :verification, :code

    def verify_code
      raise ServiceError, 'no verification found' if verification.blank? || verification.new_record?
      raise ServiceError, "code can't be blank" if code.blank?
      raise ServiceError, 'verification expired' if verification.expires_at < Time.current
      raise ServiceError, 'Code does not match' if verification.code != code

      { success: true, verification: verification }
    end
  end
end
