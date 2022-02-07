# frozen_string_literal: true

require 'acceptance_helper'

resource 'Feed' do
  parameter :page, 'for pagination (default: 1)', example: 1

  let(:page) { 1 }
  let!(:category) { create(:category, :tutorial) }
  let!(:category2) { create(:category) }

  before do
    create(:post, :public)
    create(:post, :public, category_id: category2.id.to_s)
    Post.reindex
  end

  route '/feed/home.json', 'Home' do
    get 'get home feed' do
      context 'with valid headers' do
        include_context 'authenticated request', user_session: true, posts: true
        let!(:user_configuration) { create(:user_configuration, user: user) }

        example_request '200' do
          expect(status).to eq 200
          parsed_response = JSON.parse(response_body)
          expect(parsed_response['type']).to eq 'home'
          expect(parsed_response).to include('data')
          expect(parsed_response['data'].size).to eq(2)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'media_thumbnail')).to include('original_thumb')
          expect(parsed_response.dig('data', 0, 'item', 'items', 0)).to include('media_thumbnail_dimensions')
        end
      end

      context 'without authentication headers' do
        header 'USER-AGENT', 'testing'

        example_request '422' do
          expect(status).to eq 422

          parsed_response = JSON.parse(response_body)
          expect(parsed_response['base']).to eq 'Invalid APP ID'
        end
      end
    end
  end

  route '/feed/discover.json', 'Discover' do
    get 'get discover feed' do
      context 'with valid headers' do
        include_context 'authenticated request', curated_posts: true

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response['type']).to eq 'discover'
          expect(parsed_response['data'].size).to eq(5)
        end
      end

      context 'without authentication headers' do
        header 'USER-AGENT', 'testing'

        example_request '422' do
          expect(status).to eq 422
        end
      end
    end
  end

  route '/feed/explore.json', 'Explore' do
    parameter :categories, 'when filtering with multiple categories, values should be separated by comma. e.g.: /feed/explore.json?categories=cat_id_1,cat_id_2',
              type: :string, required: false

    get 'get explore feed' do
      # context 'guest' do
      #   include_context 'authenticated request'

      #   example_request '200' do
      #     expect(status).to eq(200)
      #     expect(parsed_response['type']).to eq 'explore'
      #     expect(parsed_response['data'].size).to eq 2
      #   end
      # end

      context 'logged user' do
        include_context 'authenticated request', user_session: true
        let!(:user_configuration) { create(:user_configuration, user: user) }

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response['type']).to eq 'explore'
          expect(parsed_response['data'].size).to eq 2
        end
      end

      context 'category filter' do
        include_context 'authenticated request', user_session: true
        let!(:categories) { Category.last.id.to_s }
        let!(:user_configuration) { create(:user_configuration, user: user) }

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'category', 'id')).to eq(Category.last.id.to_s)
        end
      end
    end
  end
end
