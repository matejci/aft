# frozen_string_literal: true

require 'acceptance_helper'

resource 'User Groups' do
  include_context 'authenticated request', user_session: true

  let(:user_group) { create_user_group }
  let(:id) { user_group.id }

  route '/user_groups.json', 'User Groups List' do
    get 'get user groups' do
      before { 2.times { |n| create_user_group(n + 1) } }

      example '200' do
        do_request

        expect(status).to eq 200
        expect(parsed_response).to be_present
        expect(parsed_response).to include('user_groups', 'total_pages')
        expect(parsed_response['total_pages']).to eq(1)
      end
    end
  end

  route '/user_groups.json', 'Create User Group' do
    post 'create user group' do
      with_options scope: :user_group do
        parameter :name, required: true
        parameter :user_ids, required: true
      end

      let(:name) { 'new group' }
      let(:user_ids) { Array.new(3) { create(:user).id.to_s } }

      context '201' do
        example '201' do
          do_request

          expect(status).to eq 201
          expect(parsed_response['name']).to eq name
          expect(parsed_response['users'].map { |u| u['id'] }).to eq user_ids

          expect(parsed_response['users'].first).to include('username', 'display_name', 'verified', 'profile_thumb_url')
        end
      end

      context '422' do
        let(:name) { user_group.name }

        example '422' do
          do_request

          expect(status).to eq 422
          expect(parsed_response).to include('name')
        end
      end
    end
  end

  route '/user_groups/:id.json', 'User Group Detail' do
    get 'show user group' do
      parameter :id, 'user group id', required: true

      example '200' do
        do_request

        expect(status).to eq 200
        expect(parsed_response).to include('id', 'name', 'users')
      end
    end
  end

  route '/user_groups/:id.json', 'User Group Detail' do
    patch 'update user group' do
      parameter :id, 'user group id', required: true

      with_options scope: :user_group do
        parameter :name, required: true
        parameter :user_ids, required: true
      end

      let(:name) { 'new group name' }
      let(:user_ids) { Array.new(3) { create(:user).id.to_s } }

      context '200' do
        example '200' do
          do_request

          expect(status).to eq 200
          expect(parsed_response['name']).to eq name
          expect(parsed_response['users'].map { |u| u['id'] }).to eq user_ids
        end
      end
    end
  end

  route '/user_groups/:id.json', 'Delete User Group' do
    delete 'delete user group' do
      parameter :id, 'user group id', required: true

      example '200' do
        do_request

        expect(status).to eq 200
        expect(UserGroup.find(id)).to be_nil
      end
    end
  end
end

def create_user_group(count = 1)
  user_ids = Array.new(count) { create(:user) }.map { |user| user.id.to_s }
  create(:user_group, user: user, user_ids: user_ids)
end
