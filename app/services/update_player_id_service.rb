# frozen_string_literal: true

class UpdatePlayerIdService
  def initialize(token:, player_id:)
    @token = token
    @player_id = player_id
  end

  def call
    update_player_id
  end

  private

  attr_reader :token, :player_id

  def update_player_id
    raise ActionController::BadRequest, 'Wrong token' if token.blank?

    session = Session.active.find_by(token: token)

    raise ActionController::BadRequest, 'Wrong token' if session.blank?

    session.player_id = player_id
    session.save!
  end
end
