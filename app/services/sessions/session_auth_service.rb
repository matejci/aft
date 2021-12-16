# frozen_string_literal: true

module Sessions
  class SessionAuthService
    def initialize(request:, user:, app_token_validation:, admin_login: nil)
      @request = request
      @user = user
      @app_token_validation = app_token_validation
      @admin_login = admin_login
    end

    def call
      authenticate_session
    end

    private

    attr_reader :request, :user, :app_token_validation, :admin_login

    def authenticate_session
      # TO-DO: check if session with token exists and live status true for signed out tokens
      session = user.sessions.active.find_by(user_agent: request.user_agent)

      if session
        session.live = true
        session.last_login = Time.current
        session.player_id = request.headers['PLAYER-ID'] if request.headers['PLAYER-ID']
        session.save
      else
        session = create_user_session
      end

      session.set(admin_login: admin_login || false)
      Session.live.where(player_id: session.player_id).not(id: session.id).update_all(live: false) if session.player_id
      session
    end

    def create_user_session
      Sessions::CreateSessionService.new(request: request, app_token_validation: app_token_validation, user: user).call
    end
  end
end
