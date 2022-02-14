# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Sessions' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.appforteachers.v1'

  route '/sessions/player-id.json', 'Update Player Id' do
    patch 'Player-ID update' do
      header 'PLAYER-ID', 'test'

      context '200' do
        example_request '200' do
          expect(status).to eq(200)
          expect(user.reload.sessions.last.player_id).to eq('test')
        end
      end
    end
  end
end
