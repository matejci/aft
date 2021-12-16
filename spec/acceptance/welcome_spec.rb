# frozen_string_literal: true

require 'acceptance_helper'

resource 'Welcome' do
  include_context 'authenticated request', user_session: true

  explanation 'tutorial endpoint'

  route '/tutorial.json', 'get tutorial' do
    get 'tutorial' do
      context '200' do
        before do
          Rails.cache.clear
          category = Category.takko_tutorial_category
          post = create(:post, :public, category_id: category.id)
          create(:post, :public, parent_id: post.id, category_id: category.id)
        end

        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'tutorial')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response.dig('data', 0, 'item', 'items')).to be_an_instance_of(Array)
          expect(parsed_response.dig('data', 0, 'item', 'type')).to eq('post')
        end
      end
    end
  end
end
