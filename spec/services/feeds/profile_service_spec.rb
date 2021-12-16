# frozen_string_literal: true

require 'rails_helper'

describe Feeds::ProfileService do
  before(:each) do
    @user = create(:user)
    create(:user_configuration, user: @user)
    @viewer = create(:user)
    create(:user_configuration, user: @viewer)
  end

  context 'private posts' do
    it 'returns users private and followees posts if user is looking at his own profile' do
      prepare_private_context_data

      result = service_call('private', @user, @user)

      expect(result.size).to eq(5)
      expect(result.map(&:post).map(&:view_permission).uniq).to eq([:followees, :private])
    end

    it 'returns followees posts if user is requesting posts of user that he is following' do
      prepare_private_context_data
      @user.follow!(@viewer)

      result = service_call('private', @user, @viewer)

      expect(result.size).to eq(2)
      expect(result.map(&:post).map(&:view_permission).uniq).to eq([:followees])
    end

    it 'returns followees takkos if user is viewing his own profile' do
      @viewer.follow!(@user)
      prepare_private_context_data(with_takkos: true)

      result = service_call('private', @user, @user)

      expect(result.size).to eq(6)
      expect(result.map(&:post).map(&:view_permission).uniq).to eq([:followees, :private])
      expect(result.first.takkos.size).to eq(6)
    end

    it 'returns empty array if user is requesting private posts of user that is not being followed' do
      prepare_private_context_data

      result = service_call('private', @user, @viewer)

      expect(result.size).to eq(0)
      expect(result.map(&:post).map(&:view_permission).uniq).to eq([])
    end
  end

  context 'takkos' do
    it "returns only public takkos (which user whose profile is being requested) posted on other's posts" do
      create_takkos

      result = service_call('takkos', @user, @viewer)

      expect(result.size).to eq(2)
      expect(result.map(&:post).map(&:view_permission).uniq).to eq([:public])
    end

    it 'does not returns posts in response' do
      create_takkos

      result = service_call('takkos', @user, @viewer)

      expect(result.size).to eq(2)
      expect(result.filter_map { |item| item.post.parent_id }.compact.size).to eq(2)
    end
  end

  context 'posts' do
    it 'returns only public posts (not takkos) in response' do
      create_list(:post, 5, :public, user: @user)
      create_takkos

      result = service_call('posts', @user, @viewer)

      expect(result.size).to eq(5)
      expect(result.map(&:post).map(&:view_permission).uniq).to eq([:public])
      expect(result.filter_map { |item| item.post.parent_id }.compact.size).to eq(0)
    end
  end

  def prepare_private_context_data(with_takkos: false)
    create_list(:post, 3, user: @user)
    create_list(:post, 2, :followees, user: @user)
    create_list(:post, 1, :public, user: @user)

    return unless with_takkos

    post = create(:post, :followees, user: @user)
    takkos = create_list(:post, 5, :followees, user: @user)
    takkos.each { |takko| takko.set(parent_id: post.id) }
  end

  def create_takkos
    user = create(:user)
    post = create(:post, :public, user: user)
    takkos = create_list(:post, 2, :public, user: @user)
    takkos.each { |takko| takko.set(parent_id: post.id, own_takko: false, original_user_id: user.id) }
  end

  def service_call(post_type, user, viewer)
    Feeds::ProfileService.new(posts_type: post_type, user: user, viewer: viewer, order: nil, page: nil).call[:posts]
  end
end
