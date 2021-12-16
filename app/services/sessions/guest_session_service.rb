# frozen_string_literal: true

module Sessions
  class GuestSessionService
    def initialize(request:, app_token_validation:)
      @request = request
      @app_token_validation = app_token_validation
    end

    def call
      prepare_guest_session
    end

    private

    attr_reader :request, :app_token_validation

    def prepare_guest_session
      guest_session = Session.guest.active.find_by(ip_address: request.remote_ip, user_agent: request.user_agent)

      current_session = if guest_session
        guest_session.set(last_activity: Time.current)
      else
        create_guest_session
      end

      { current_user: nil, current_session: current_session }
    end

    def create_guest_session
      Sessions::CreateSessionService.new(request: request, app_token_validation: app_token_validation).call
    end
  end
end
