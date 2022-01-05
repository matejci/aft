# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate_user
    end

    private

    def authenticate_user
      session = Session.includes(:user).live.find_by(token: request.headers['HTTP-ACCESS-TOKEN'])

      reject_unauthorized_connection unless session&.user&.active?

      session.user
    end
  end
end
