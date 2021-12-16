# frozen_string_literal: true

require 'acceptance_helper'

resource 'Profiles' do
  explanation <<~DOC
    user session (HTTP-ACCESS-TOKEN) is required for:
    - getting folllowers/followees list
    - performing action items (follow/unfollow/block/unblock)
  DOC

  include_context 'authenticated request', user_session: true

  parameter :username, "profile user's username", required: true

  before { create(:user_configuration, user: user) }

  let(:username) { user.username }

  route '/profiles/:username/user.json', 'User' do
    get 'get user information' do
      context 'with username' do
        example '200' do
          do_request

          expect(status).to eq 200
          parsed_response = JSON.parse(response_body)
          expect(parsed_response).to include user_json(user)
          expect(parsed_response.keys).to include(*%w[owner following blocked])
          expect(parsed_response['owner']).to be true
        end
      end

      context 'without username' do
        let(:username) { nil }

        example '422' do
          do_request

          expect(status).to eq 422
          expect(response_body).to eq({ base: 'Profile user not found' }.to_json)
        end
      end
    end
  end

  context 'profile feed' do
    route '/profiles/:username/posts/p/:page.json', 'Posts' do
      parameter :page, 'for pagination (default: 1)', example: 1

      get 'get posts' do
        example_request '200' do
          expect(status).to eq 200
          expect(JSON.parse(response_body).class).to eq Array
        end
      end
    end

    route '/profiles/:username/takkos/p/:page.json', 'Posts' do
      parameter :page, 'for pagination (default: 1)', example: 1

      get 'get takkos' do
        example_request '200' do
          expect(status).to eq 200
        end
      end
    end

    route '/profiles/:username/private/p/:page.json', 'Posts' do
      parameter :page, 'for pagination (default: 1)', example: 1

      get 'get private posts/takkos' do
        example_request '200' do
          expect(status).to eq 200
        end
      end
    end
  end

  route '/profiles/:username/followees/p/:page.json', 'Followees List' do
    get 'get followees list' do
      context '200' do
        parameter :page, 'for pagination (default: 1)', example: 1

        before { 5.times { user.follow!(create(:user)) } }

        example_request '200' do
          expect(status).to eq 200
          expect(headers['HTTP-ACCESS-TOKEN']).not_to be_nil
          expect(JSON.parse(response_body).length).to eq 5
        end
      end

      context 'without user session' do
        before { header 'HTTP-ACCESS-TOKEN', nil }

        example_request '422' do
          expect(status).to eq 422
          expect(headers['HTTP-ACCESS-TOKEN']).to be_nil
          expect(response_body).to eq({ base: 'No user session' }.to_json)
        end
      end
    end

    route '/profiles/:username/followers/p/:page.json', 'Followers List' do
      parameter :page, 'for pagination (default: 1)', example: 1

      before { 37.times { create(:user).follow!(user) } }

      get 'get followers list' do
        example_request '200' do
          parsed_response = JSON.parse(response_body)
          expect(parsed_response.length).to eq 36
          expect(status).to eq 200
        end

        example_request '200: page 2', page: 2 do
          parsed_response = JSON.parse(response_body)
          expect(parsed_response.length).to eq 1

          expect(parsed_response.first).to eq user_json(Follow.first.follower).merge('following' => false)
          expect(status).to eq 200
        end
      end
    end
  end

  context 'action items' do
    let(:user_conf) { create(:user_configuration, user: create(:user, username: 'user_b')) }
    let(:username) { user_conf.user.username }

    route '/profiles/:username/follow.json', 'follow profile user' do
      post 'follow user' do
        example_request '201' do
          expect(status).to eq 201
        end
      end
    end

    route '/profiles/:username/unfollow.json', 'unfollow profile user' do
      delete 'unfollow user' do
        example_request '200' do
          expect(status).to eq 200
        end
      end
    end

    route '/profiles/:username/block.json', 'block profile user' do
      post 'block user' do
        example_request '201' do
          expect(status).to eq 201
        end
      end
    end

    route '/profiles/:username/unblock.json', 'unblock profile user' do
      delete 'unblock user' do
        example_request '200' do
          expect(status).to eq 200
        end
      end
    end
  end
end
