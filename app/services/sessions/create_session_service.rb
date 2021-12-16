# frozen_string_literal: true

module Sessions
  class CreateSessionService
    def initialize(request:, app_token_validation:, user: nil)
      @request = request
      @app_token_validation = app_token_validation
      @user = user
    end

    def call
      create_session
    end

    private

    attr_reader :request, :app_token_validation, :user

    def create_session
      return unless app_token_validation[:success]

      app = App.find_by(app_id: app_token_validation[:app_id])

      Session.new.tap do |s|
        s.app = app
        s.ip_address = request.remote_ip
        s.user_agent = request.user_agent
        s.last_login = Time.current
        client = DeviceDetector.new(request.user_agent)
        s.device_name = client.device_name
        s.device_type = client.device_type
        s.device_client_name = client.name
        s.device_client_full_version = client.full_version
        s.device_os = client.os_name
        s.device_os_full_version = client.os_full_version
        s.device_client_known = client.known?
        s.player_id = request.headers['PLAYER-ID']

        if user
          s.user = user

          s.access_token = loop do
            access_token = SecureRandom.urlsafe_base64(50, false)
            break access_token unless Session.where(access_token: access_token).exists?
          end

          s.token = JWT.encode({ access_token: s.access_token }, app.secret + request.user_agent, 'HS512')
        else
          s.live = false # guest user does not sign in/out
        end

        s.save
      end
    end
  end
end
