# frozen_string_literal: true

require 'acceptance_helper'

resource 'Dashboard' do
  include_context 'authenticated request', user_session: true

  route '/dashboard.json', 'dashboard' do
    post 'get dashboard data' do
      example_request '200' do
        expect(status).to eq 200
      end
    end
  end
end
