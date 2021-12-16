# frozen_string_literal: true

require 'acceptance_helper'

resource 'Comments' do
  include_context 'authenticated request', user_session: true

  explanation 'Comments'

  let!(:category) { create(:category) }
  let!(:post_with_comments) { create(:post, :public) }
  let!(:comments) { create_list(:comment, 20, post_id: post_with_comments.id) }
  let!(:post_without_comments) { create(:post, :public) }

  route '/posts/:post_id/comments.json', 'comments of specific post, without pagination params' do
    parameter :post_id, required: true

    get 'comments' do
      context 'response with comments - 200' do
        let(:post_id) { post_with_comments.id }

        example_request '200 - with comments' do
          expect(status).to eq(200)
          expect(parsed_response).to include('total_pages' => 2)
          expect(parsed_response).to include('comments')
          expect(parsed_response['comments']).to be_an_instance_of(Array)
          expect(parsed_response['comments'].size).to eq(10)
          expect(parsed_response).to be_an_instance_of(Hash)
        end
      end

      context 'response without comments - 200' do
        let(:post_id) { post_without_comments.id }

        example_request '200 - no comments' do
          expect(status).to eq(200)
          expect(parsed_response).to include('total_pages' => 0)
          expect(parsed_response).to include('comments')
          expect(parsed_response['comments']).to be_an_instance_of(Array)
          expect(parsed_response['comments'].size).to eq(0)
          expect(parsed_response).to be_an_instance_of(Hash)
        end
      end
    end
  end

  route '/posts/:post_id/comments.json?page=1&per_page=5', 'comments of specific post, with pagination params' do
    parameter :post_id, required: true
    parameter :page
    parameter :per_page

    get 'comments with pagination params' do
      context '200' do
        let(:post_id) { post_with_comments.id }
        example_request '200 with pagination' do
          expect(status).to eq(200)
          expect(parsed_response).to include('total_pages' => 4)
          expect(parsed_response).to include('comments')
          expect(parsed_response).to include('comments_count')
          expect(parsed_response['comments']).to be_an_instance_of(Array)
          expect(parsed_response['comments'].size).to eq(5)
          expect(parsed_response).to be_an_instance_of(Hash)
        end
      end
    end
  end
end
