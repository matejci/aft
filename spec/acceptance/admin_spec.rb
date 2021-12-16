# frozen_string_literal: true

require 'acceptance_helper'

resource 'Admin' do
  include_context 'authenticated request', user_session: true

  parameter :page,  'for pagination (default: 1)', example: 1
  parameter :query, 'search term'

  let!(:user1) { create(:user, username: 'blossom', display_name: 'Blossom Girl', email: 'bl@powerpuff.com', phone: '+123-4567') }
  let!(:user2) { create(:user, username: 'bubbles', display_name: 'Bubbles Girl', email: 'bubble@powerpuff.com', phone: '+890-4444') }
  let!(:user3) { create(:user, username: 'buttercup', display_name: 'Buttercup Girl', email: 'butter@powerpuff.com', phone: '+888-8888') }
  let(:page) { 1 }

  before do
    User.reindex
    user.update!(admin_role: 'super_administrator')
  end

  route '/admin/users/:id/verify', 'verify user' do
    let(:id) { user.id }

    post 'verify user' do
      context 'when user is unverified' do
        before { user.set(verified: false) }

        example_request '200' do
          expect(user.reload.verified).to be_truthy
        end
      end

      context 'when user is verified' do
        before { user.set(verified: true) }

        example_request '200' do
          expect(user.reload.verified).to be_falsy
        end
      end
    end
  end

  route '/admin/users', 'Get users' do
    get 'users' do
      context 'when no search term' do
        let(:query) { '' }

        example_request 'list all users' do
          expect(status).to eq 200
          expect(response_body).to include('blossom')
          expect(response_body).to include('bubbles')
          expect(response_body).to include('buttercup')
        end
      end

      context 'when searching by username' do
        let(:query) { 'blossom' }

        example_request 'users search by username' do
          expect(status).to eq 200
          expect(response_body).to include('blossom')
          expect(response_body).to_not include('bubbles')
          expect(response_body).to_not include('buttercup')
        end
      end

      context 'when search by display_name' do
        let(:query) { 'Bubbles' }

        example_request 'users search by display_name' do
          expect(status).to eq 200
          expect(response_body).to include('bubbles')
          expect(response_body).to_not include('blossom')
          expect(response_body).to_not include('buttercup')
        end
      end

      context 'when search by email' do
        let(:query) { 'butter@powerpuff.com' }

        example_request 'users search by email' do
          expect(status).to eq 200
          expect(response_body).to include('buttercup')
          expect(response_body).to_not include('blossom')
          expect(response_body).to_not include('bubbles')
        end
      end

      context 'when search by phone' do
        let(:query) { '890-4444' }

        example_request 'users search by phone' do
          expect(status).to eq 200
          expect(response_body).to include('bubbles')
          expect(response_body).to_not include('blossom')
          expect(response_body).to_not include('buttercup')
        end
      end
    end
  end
end
