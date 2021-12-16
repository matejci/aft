# frozen_string_literal: true

class AppTokenValidationService
  class AppVersionError < StandardError
    attr_reader :response_object

    def initialize(response)
      super

      @response_object = {
        base: response[:base],
        latest_version: response[:latest_version],
        your_version: response[:your_version],
        link: response[:link]
      }
    end
  end

  class AppError < StandardError
    attr_reader :response_object

    def initialize(response)
      super

      @response_object = response
    end
  end

  def initialize(request:)
    @app_token = request.headers['HTTP-X-APP-TOKEN']
    @app_id = request.headers['APP-ID']
    @app_version = request.headers['APP-VERSION']
    @user_agent = request.user_agent
  end

  def call
    validate_app_tokens
  end

  private

  attr_reader :app_token, :app_id, :app_version, :user_agent

  def validate_app_tokens
    app = App.find_by(app_id: app_id)

    raise AppError, { base: 'Invalid APP ID' } if app.nil?

    if version_supported?(app)
      decoded_token = JWT.decode(app_token, app.secret + user_agent, true, { algorithm: 'HS512' })

      app_query = App.find_by(app_id: decoded_token.dig(0, 'app_id'), public_key: decoded_token.dig(0, 'public_key'))

      raise AppError, { base: 'Unauthorized' } unless app_query
      raise AppError, { base: 'Unauthorized app credentials' } if app_query.status != true

      { success: true, app_id: decoded_token.dig(0, 'app_id'), app: app_query }
    else
      response = { base: 'Oops, you appear to be in a time machine. Please update to the latest app version!',
                   latest_version: app.version,
                   your_version: app_version,
                   link: 'https://apps.apple.com/app/1600466655' }

      raise AppVersionError.new(response), 'Wrong APP version'
    end
  rescue JWT::VerificationError => e
    raise AppError, { base: "Invalid APP Token (JWT::VerificationError): #{e.message}" }
  rescue JWT::DecodeError => e
    raise AppError, { base: "Invalid APP Token (JWT::DecodeError): #{e.message}" }
  rescue JWT::ExpiredSignature => e
    raise AppError, { base: "Invalid APP Token (JWT::ExpiredSignature): #{e.message}" }
  rescue JWT::ImmatureSignature => e
    raise AppError, { base: "Invalid APP Token (JWT::ImmatureSignature): #{e.message}" }
  rescue JWT::InvalidIssuerError => e
    raise AppError, { base: "Invalid APP Token (JWT::InvalidIssuerError): #{e.message}" }
  rescue JWT::InvalidJtiError => e
    raise AppError, { base: "Invalid APP Token (JWT::InvalidJtiError): #{e.message}" }
  rescue JWT::InvalidAudError => e
    raise AppError, { base: "Invalid APP Token (JWT::InvalidAudError): #{e.message}" }
  end

  def version_supported?(app)
    return true if app.web?
    return true if ENV.fetch('HEROKU_ENV', nil) != 'production'

    app.supported_versions.include?(app_version)
  end
end
