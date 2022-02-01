# frozen_string_literal: true

require 'acceptance_helper'

resource 'Posts' do
  explanation <<~EXPLANATION
    - `/posts/:id.json` for showing post + carousel
    - `can_comment/can_takko/voted` are available only when viewer is present
    - `/posts/:id/edit.json` for pre-filling edit post form
    - only owner can access this info
  EXPLANATION

  include_context 'authenticated request', user_session: true

  before { create(:user_configuration, user: user) }

  let(:post) { create(:post, :public, user: user) }
  let(:id) { post.id }

  route '/posts/:id.json', 'Post' do
    get 'get post + carousel items' do
      parameter :id, 'post id', required: true

      context 'owner' do
        example '200' do
          do_request

          expect(status).to eq 200
        end
      end

      context 'guest' do
        before { header 'HTTP-ACCESS-TOKEN', nil }

        example '200: guest' do
          do_request

          expect(status).to eq 200
        end
      end
    end
  end

  route '/posts/:id/edit.json', 'Edit Post' do
    get 'edit post' do
      parameter :id, 'post id', required: true

      context 'owner' do
        example '200' do
          do_request

          expect(status).to eq 200
        end
      end

      context 'non-owner' do
        before { header 'HTTP-ACCESS-TOKEN', nil }

        example '403: non-owner' do
          do_request

          expect(status).to eq 403
        end
      end
    end
  end

  route '/posts/:id/upvote.json', 'Upvote' do
    post 'toggle upvote' do
      parameter :id, 'post id', required: true

      context 'up' do
        example '200' do
          do_request

          expect(status).to eq 200
        end
      end

      context 'cancel upvote' do
        before { Upvote.toggle(post, user) }

        example '200: cancel upvote' do
          do_request

          expect(status).to eq 200
        end
      end
    end
  end

  route '/posts.json', 'Create post' do
    post 'create post' do
      with_options scope: :post do
        parameter :category_id, required: true
        parameter :title, required: true
        parameter :animated_cover, required: true
        parameter :media_file, required: true
        parameter :media_thumbnail, required: true
        parameter :video_length, required: true
        parameter :view_permission, required: true
        parameter :takko_permission, required: true
        parameter :description, required: true
        parameter :viewer_ids, 'array of user ids who can view'
        parameter :viewer_group_ids, 'array of user group ids who can view'
        parameter :takkoer_ids, 'array of user ids who can takko'
        parameter :takkoer_group_ids, 'array of user group ids who can takko'
        parameter :media_type
      end

      before do
        create(:category, :tutorial)
        create(:configuration, app: App.first)
      end

      let(:category) { create(:category) }
      let(:media_file) { Rack::Test::UploadedFile.new('spec/fixtures/media_file.mp4', 'video/mp4') }
      let(:animated_cover) { Rack::Test::UploadedFile.new('spec/fixtures/media_file.mp4', 'video/mp4') }
      let(:media_thumbnail) { Rack::Test::UploadedFile.new('spec/fixtures/media_thumbnail.png', 'image/png') }
      let(:video_length) { 5 }
      let(:title) { 'new post' }
      let(:category_id) { category.id }
      let(:description) { 'blabla' }

      context '201' do
        example '201' do
          do_request

          expect(status).to eq 201
          expect(parsed_response).to include('id', 'category_id', 'link', 'title', 'total_views', 'media_thumbnail_url', 'media_file_url', 'minimum_video_length', 'media_type')
        end
      end

      context 'custom permission' do
        let(:takko_permission) { 'custom' }

        context '201' do
          let(:takkoer) { create(:user) }
          let(:viewer_1) { create(:user) }
          let(:viewer_2) { create(:user) }
          let(:viewer_3) { create(:user) }
          let(:view_permission) { 'custom' }
          let(:takkoer_ids) { [takkoer.id.to_s] }
          let(:viewer_ids) { [viewer_3.id.to_s] }
          let(:user_group) { create(:user_group, user: user, users: [viewer_1, viewer_2]) }
          let(:viewer_group_ids) { [user_group.id.to_s] }

          example '201' do
            do_request

            expect(status).to eq 201
            post = Post.last
            expect(post.takkoer_ids).to eq(takkoer_ids)
            expect(post.viewer_ids).to eq(viewer_ids + user_group.users.map { |user| user.id.to_s })
          end
        end

        context '422' do
          let(:viewer_ids) { [] }

          example '422' do
            do_request

            expect(status).to eq 422
            expect(parsed_response).to include('takkoer_ids')
          end
        end
      end
    end
  end

  route '/posts/:id/takkos.json', 'View all takkos' do
    explanation <<~DOCS
      - API will accept 5 different `order` param values: `comments`, `newest`, `oldest`, `upvotes` and `views`
      - if `order` param is not used, API will fallback to `Post`'s order setting
    DOCS

    before do
      takkos = create_list(:post, 10)
      takkos.each_with_index { |takko, ind| takko.set(parent_id: post.id, total_views: ind, upvotes_count: ind, comments_count: ind, media_type: 'video') }
    end

    get 'takkos' do
      parameter :id, required: true
      parameter :order
      parameter :page
      parameter :per_page

      context 'without order param' do
        example_request '200' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('total_pages', 'data', 'takkos_count')
          expect(parsed_response['total_pages']).to eq(2)
          expect(parsed_response['takkos_count']).to eq(10)
          expect(parsed_response.dig('data', 'items').size).to eq(8)
          expect(parsed_response.dig('data', 'items', 0).keys).to include('id', 'link', 'title', 'publish_date', 'description', 'media_file_url',
                                                                          'video_length', 'video_transcoded', 'media_thumbnail_dimensions', 'published',
                                                                          'media_thumbnail', 'master_playlist', 'user', 'category', 'total_views',
                                                                          'comments_count', 'upvotes_count', 'media_type')
        end
      end

      context 'with order params' do
        let(:order) { :comments }

        example_request '200 - ordered by comments count' do
          expect(status).to eq(200)
          comments_count1 = parsed_response.dig('data', 'items', 1, 'comments_count')
          comments_count2 = parsed_response.dig('data', 'items', 2, 'comments_count')
          comments_count3 = parsed_response.dig('data', 'items', 3, 'comments_count')
          expect(comments_count1).to be > (comments_count2)
          expect(comments_count3).to be < (comments_count2)
        end
      end
    end
  end
end
