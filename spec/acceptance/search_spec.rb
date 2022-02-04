# frozen_string_literal: true

require 'acceptance_helper'

resource 'Search' do
  include_context 'authenticated request'

  parameter :page,  'for pagination (default: 1)', example: 1
  parameter :query, 'search term'

  let!(:cat)    { create(:user, username: 'catt') }
  let!(:tom)    { create(:user, username: 'tomm') }
  let!(:apple)  { create(:post, :public, user: cat) }
  let!(:banana) { create(:post, :public, user: tom) }
  let(:page)    { 1 }

  before do
    Post.search_index.refresh
    User.reindex
  end

  route '/search/posts.json', 'Posts Search' do
    get 'posts search' do
      context 'search username' do
        let(:query) { 'tom' }

        example_request 'posts search by user' do
          parsed_response = JSON.parse(response_body)

          expect(status).to eq 200
          expect(parsed_response.size).to eq 2
          expect(parsed_response.dig('data', 0, 'item', 'selected_id')).to eq banana.id.to_s
        end
      end

      context 'no search term' do
        example_request 'posts search: no search term' do
          explanation 'error with message'

          expect(status).to eq 400
          expect(JSON.parse(response_body)).to include('error')
          expect(JSON.parse(response_body)['error']).to eq 'Please provide search term'
        end
      end
    end

    # TODO: test search permission
    # TODO: move search functionality testing to unit tests
  end

  route '/search/users.json', 'users search' do
    get 'users search' do
      let(:query) { 'cat' }

      example_request '200' do
        parsed_response = JSON.parse(response_body)

        expect(status).to eq 200
        expect(parsed_response.size).to eq 2
        expect(parsed_response.dig('data', 0, 'id')).to eq cat.id.to_s
      end
    end
  end

  route '/search.json', 'users + posts search' do
    get 'users + posts search' do
      let(:query) { 'cat' }

      response_field :users, 'users/list'
      response_field :posts, 'posts/list'

      example_request '200' do
        parsed_response = JSON.parse(response_body)

        expect(status).to eq 200
        expect(parsed_response).to have_key('users')
        expect(parsed_response).to have_key('posts')
        expect(parsed_response['users'].size).to eq 1
        expect(parsed_response['posts'].size).to eq 1
        expect(parsed_response['users'].first['id']).to eq cat.id.to_s
        expect(parsed_response['posts'].first['item']['selected_id']).to eq apple.id.to_s
      end
    end
  end

  route '/search/hashtags.json', 'hashtags search' do
    get 'all posts that include particular hashtag' do
      parameter :query, required: true
      parameter :page
      parameter :per_page

      before do
        posts = create_list(:post, 3)
        create(:post, description: 'DESC #takko')
        create(:post)
        create(:hashtag, post_ids: posts.pluck(:id))
      end

      context 'without paginate params' do
        let(:query) { 'takko' }

        example_request '200' do
          expect(status).to eq(200)

          parsed_response = JSON.parse(response_body)

          expect(parsed_response).to be_an_instance_of(Hash)
          expect(parsed_response['posts_count']).to eq(1)
          expect(parsed_response.keys).to include('total_pages', 'posts_count', 'data')
        end
      end

      context 'with paginate params' do
        let(:query) { 'takko' }
        let(:page) { 2 }
        let(:per_page) { 2 }

        example_request '200' do
          expect(status).to eq(200)

          parsed_response = JSON.parse(response_body)

          expect(parsed_response).to be_an_instance_of(Hash)
          expect(parsed_response['posts_count']).to eq(1)
          expect(parsed_response['data'].size).to eq(0)
        end
      end

      context 'no posts for given hashtag' do
        let(:query) { 'empty' }

        example_request '200' do
          expect(status).to eq(200)

          parsed_response = JSON.parse(response_body)

          expect(parsed_response).to be_an_instance_of(Hash)
          expect(parsed_response['posts_count']).to eq(0)
          expect(parsed_response['data']).to be_empty
        end
      end

      context 'no query param' do
        let(:query) { '' }

        example_request '200' do
          expect(status).to eq(400)

          parsed_response = JSON.parse(response_body)

          expect(parsed_response).to include('error')
          expect(parsed_response['error']).to eq('Missing query param')
        end
      end
    end
  end
end
