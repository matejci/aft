# frozen_string_literal: true

module Sessions
  class SessionValidationService
    def initialize(token:, request:)
      @token = token
      @request = request
    end

    def call
      validate_session
    end

    private

    attr_reader :token, :request

    # rubocop:disable Metrics/PerceivedComplexity
    def validate_session
      app = App.find_by(app_id: request.headers['APP-ID'])

      if app
        decoded_token = JWT.decode(token, app.secret + request.user_agent, true, { algorithm: 'HS512' })
        session = Session.find_by(access_token: decoded_token.dig(0, 'access_token'))

        if session
          if session.valid? && session.status == true
            session.last_activity = Time.current
            session.live = true
            session.save
            session
          else
            { success: false, base: 'Invalid or inactive session' }
          end
        else
          { success: false, base: 'Unauthorized' }
        end

      else
        { success: false, base: 'Invalid access' }
      end
    rescue JWT::VerificationError => e
      { success: false, base: "JWT::VerificationError: #{e.message}" }
    rescue JWT::DecodeError => e
      { success: false, base: "JWT::DecodeError: #{e.message}" }
    rescue JWT::ExpiredSignature => e
      { success: false, base: "JWT::ExpiredSignature: #{e.message}" }
    rescue JWT::ImmatureSignature => e
      { success: false, base: "JWT::ImmatureSignature: #{e.message}" }
    rescue JWT::InvalidIssuerError => e
      { success: false, base: "JWT::InvalidIssuerError: #{e.message}" }
    rescue JWT::InvalidAudError => e
      { success: false, base: "JWT::InvalidAudError: #{e.message}" }
    rescue JWT::InvalidJtiError => e
      { success: false, base: "JWT::InvalidJtiError: #{e.message}" }
    end
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
