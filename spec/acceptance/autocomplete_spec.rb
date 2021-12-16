# frozen_string_literal: true

require 'acceptance_helper'

resource 'Autocomplete', search: true do
  explanation <<~EXPLANATION
    - user session (HTTP-ACCESS-TOKEN) is required
  EXPLANATION

  route '/autocomplete/hashtags.json', 'autocomplete hashtags' do
    include_context 'authenticated request'

    parameter :query, 'hashtag query'

    before do
      %w[abc_a abc_b abc_c def_d def_e].each { |hashtag| Hashtag.create!(name: hashtag) }
      Hashtag.reindex
    end

    get 'hashtags' do
      example_request '200' do
        expect(status).to eq 200
        expect(parsed_response).to eq %w[abc_a abc_b abc_c def_d def_e]
      end

      context 'with query' do
        let(:query) { 'ab' }

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response).to eq %w[abc_a abc_b abc_c]
        end
      end

      context 'popularity' do
        before do
          user = create(:user)
          post = create(:post, user: user)

          2.times { post.comments.create!(text: '#abc_b', user: user) }
          5.times { post.comments.create!(text: '#def_d', user: user) }

          Hashtag.reindex
        end

        example_request '200' do
          expect(status).to eq 200
          expect(parsed_response).to eq %w[def_d abc_b abc_a abc_c def_e]
        end
      end
    end
  end

  route '/autocomplete/usernames.json', 'autocomplete usernames' do
    include_context 'authenticated request', user_session: true

    parameter :post_id, 'id of post (where user is commenting to)'
    parameter :query, 'username query'

    let!(:post_owner) { create(:user, username: 'post_owner') }
    let!(:post) { create(:post, user: post_owner) }

    before do
      %w[abc_a abc_b abc_c def_d def_e].each do |username|
        create(:user, username: username)
      end

      User.reindex
    end

    get 'usernames' do
      let(:post_id) { post.id }

      example_request '200' do
        expect(status).to eq 200
        expect(parsed_response.map { |u| u['username'] }).to include(post_owner.username, 'abc_a', 'abc_b', 'abc_c', 'def_d', 'def_e')

        user_data = parsed_response[0]
        expect(user_data['username']).to eq post_owner.username
        expect(user_data['display_name']).to eq post_owner.display_name
        expect(user_data['profile_thumb_url']).to eq post_owner.profile_thumb_url
        expect(user_data['verified']).to eq post_owner.verified
      end

      context 'with query' do
        let(:query) { 'de' }

        example_request '200' do
          expect(status).to eq 200

          expect(parsed_response.map { |u| u['username'] }).to eq %w[def_d def_e]
        end
      end
    end
  end
end
