# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Comments' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.appforteachers.v1'

  before do
    create(:post, :public)
  end

  route '/comments/:id/upvote.json', 'upvote a comment' do
    post 'comment upvote' do
      parameter :id, required: true

      context '200' do
        let(:id) { create(:comment, post: Post.last, user: user).id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          parsed_response = JSON.parse(response_body)

          expect(parsed_response).to include({ 'upvotes_count' => 1, 'voted' => 'up' })
        end
      end

      context '400' do
        let(:id) { '123pk123pk1023' }

        example_request '400' do
          expect(status).to eq(400)
          expect(JSON.parse(response_body)).to include('error' => 'Comment not found')
        end
      end
    end
  end
end
