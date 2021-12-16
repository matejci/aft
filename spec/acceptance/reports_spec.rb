# frozen_string_literal: true

require 'acceptance_helper'

resource 'Reports' do
  explanation <<~DOCS
    +  `/reports/:entity` endpoint is used to report particular entity in case of inappropriate content or similar
    + currently, 3 enities are supported: `Post` (`/reports/post`), `User` (`/reports/user`) and `Comment` (`/reports/comment`)
    + when calling the endpoint you must pass 2 params:
      `identifier` - which can be any attribute of entity model (for `User`, it can be `id`, `username`, `phone`, `email`...
                                                                 for `Post` it can be `id`, `link`, for `Comment` it can be `id`, `link`)
    + `identifier_value` - which is a value that coresponds to used identifier
    + Note that backend prefers that you use `id` attribute as 'identifier' if possible
  DOCS

  include_context 'authenticated request', user_session: true

  route '/reports/user.json', 'User/Profile reporting' do
    post 'report inappropriate profile' do
      header 'Content-Type', 'application/json'

      parameter :identifier, required: true
      parameter :identifier_value, required: true
      parameter :reason

      let(:new_user) { create(:user) }
      let(:identifier) { :id }
      let(:identifier_value) { new_user.id.to_s }
      let(:raw_post) { params.to_json }

      context 'success' do
        example_request '200' do
          expect(status).to eq 200
          parsed_response = JSON.parse(response_body)
          expect(parsed_response).to include('success' => 'Thank you for reporting')
        end
      end
    end
  end
end
