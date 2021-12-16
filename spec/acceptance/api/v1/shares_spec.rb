# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Shares' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.takko.v1'

  parameter :post_id, required: true

  route '/shares/posts/:post_id.json', 'Create new post share' do
    post 'New post share' do
      context '200' do
        let(:post_id) { create(:post, :public, user: user).id.to_s }

        example_request '201' do
          expect(status).to eq(201)
          expect(JSON.parse(response_body)['shares_count']).to eq(1)
          expect(Post.last.shares_count).to eq(1)
        end
      end

      context '400' do
        let(:post_id) { 'bla' }

        example_request '400' do
          expect(status).to eq(400)
          expect(JSON.parse(response_body)['error']).to eq('Wrong post_id')
        end
      end
    end
  end
end
