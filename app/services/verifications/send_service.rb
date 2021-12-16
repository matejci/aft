# frozen_string_literal: true

module Verifications
  class SendService
    include ServiceErrorHandling

    def initialize(verification:)
      @verification = verification
    end

    private

    attr_reader :user, :verification

    def prepare_verification
      if verification.attempts.any?
        verification.attempts = [] if verification.attempts.last < 15.minutes.ago

        if verification.attempts.length >= 3
          raise(
            ServiceError,
            'You are sending too many requests. Wait a bit and try again'
          )
        end
      end

      verification.code = rand 1000..9999
      verification.attempts << Time.current
      verification.save!
    end
  end
end
