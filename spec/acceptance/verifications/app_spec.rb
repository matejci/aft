# frozen_string_literal: true

require 'acceptance_helper'

resource 'App' do
  explanation <<~DOCS
    - Apps endpoints
  DOCS

  include_context 'configuration'

  route '/apps/configuration.json', 'configuration' do
    get "get app's configuration" do
      context 'success' do
        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response).to include('ads')
        end
      end
    end
  end
end
