# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Bookmarks' do
  include_context 'authenticated request', user_session: true

  header 'X-API-VERSION', 'api.takko.v1'

  before { create(:user_configuration, user: user) }

  route '/bookmarks.json', 'Add bookmark' do
    post 'Add bookmark' do
      parameter :post_id, required: true

      context '200' do
        let(:post_id) { create(:post, :public, user: user).id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(response_body).to be_empty
          expect(user.configuration.reload.bookmarks).to include(post_id)
        end
      end

      context '400' do
        example_request '400' do
          expect(status).to eq(400)
        end
      end
    end
  end

  route '/bookmarks/:post_id.json', 'Remove bookmark' do
    delete 'Remove bookmark' do
      parameter :post_id, required: true

      context '200' do
        let(:post_id) { create(:post, :public, user: user).id.to_s }

        example_request '200' do
          expect(status).to eq(200)
          expect(response_body).to be_empty
        end
      end
    end
  end

  route '/bookmarks.json', 'Get all bookmarks' do
    get 'Get all bookmarks' do
      parameter :page

      context '200 - no bookmarks' do
        example_request '200 - no bookmarks' do
          expect(status).to eq(200)
          expect(JSON.parse(response_body)['data']).to be_empty
        end
      end

      context '200' do
        before do
          post = create(:post, :public, user: user)
          user.configuration.bookmarks << post.id.to_s
          user.configuration.save!
          Post.reindex
        end

        example_request '200' do
          expect(status).to eq(200)
          parsed_response = JSON.parse(response_body)

          expect(parsed_response['data'].size).to eq(1)
          expect(parsed_response['total_pages']).to eq(1)
          expect(parsed_response['type']).to eq('bookmarks')
        end
      end
    end
  end
end
