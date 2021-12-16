# frozen_string_literal: true

require 'rails_helper'

describe AutocompleteUsernameService, type: :model do
  let!(:user) { create(:user, username: 'viewer') }
  let!(:stranger) { create(:user, username: 'abc_a') }
  let!(:commenter) { create(:user, username: 'abc_b') }
  let!(:follower) { create(:user, username: 'abc_c') }
  let!(:followee) { create(:user, username: 'def_d') }
  let!(:mutual_follow) { create(:user, username: 'def_e') }
  let!(:post_owner) { create(:user, username: 'def_f') }
  let!(:post) { create(:post, user: post_owner) }

  describe '#call' do
    subject(:users) do
      AutocompleteUsernameService.new(
        user: viewer, post_id: post_id, query: query
      ).call
    end

    let(:viewer) { user }
    let(:post_id) { post.id }
    let(:query) { '' }

    it 'owner first' do
      expect(users.pluck(:username)).to eq [post_owner.username] + %w[abc_a abc_b abc_c def_d def_e]
    end

    context 'owner, commenter' do
      before do
        post.comments.create!(text: 'good', user: commenter)
        User.reindex
      end

      it 'owner, commenter' do
        expect(users.pluck(:username)).to eq(
          [post_owner, commenter].map(&:username) + %w[abc_a abc_c def_d def_e]
        )
      end

      context 'owner, follower, commenter' do
        before do
          follower.follow! user
          User.reindex
        end

        it 'owner, follower, commenter' do
          expect(users.pluck(:username)).to eq(
            [post_owner, follower, commenter].map(&:username) + %w[abc_a def_d def_e]
          )
        end

        context 'owner, followee, follower, commenter' do
          before do
            user.follow! followee
            User.reindex
          end

          it 'owner, followee, follower, commenter' do
            expect(users.pluck(:username)).to eq(
              [post_owner, followee, follower, commenter].map(&:username) + %w[abc_a def_e]
            )
          end

          context 'owner, mutual_follow, followee, follower, commenter' do
            before do
              user.follow! mutual_follow
              mutual_follow.follow! user
              User.reindex
            end

            it 'owner, mutual_follow, followee, follower, commenter' do
              expect(users.pluck(:username)).to eq(
                [post_owner, mutual_follow, followee, follower, commenter].map(&:username) +
                  ['abc_a']
              )
            end
          end

          context 'query' do
            let(:query) { 'abc_a' }

            it 'owner, mutual_follow, followee, follower, commenter' do
              expect(users.pluck(:username)).to eq ['abc_a']
            end
          end
        end
      end
    end
  end
end
