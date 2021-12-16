# frozen_string_literal: true

require 'rails_helper'

describe Feeds::ExploreService do
  before(:each) do
    create(:category, :tutorial)
    @user = create(:user)
    prepare_explore_data
    Post.reindex
  end

  context 'logged user' do
    it 'returns all public posts' do
      create(:user_configuration, user: @user)
      result = Feeds::ExploreService.new(user: @user, page_number: 1, feed_type: 'explore').call

      expect(result[:posts].size).to eq(3)
      expect(result[:posts].map(&:post).map(&:view_permission).uniq).to eq([:public])
    end

    it 'does not return posts from blocked user' do
      user = create(:user)
      user2 = create(:user)
      create_list(:post, 3, :public, user: user)
      user2.block!(user)
      Post.reindex
      create(:user_configuration, user: user2)

      result = Feeds::ExploreService.new(user: user2, page_number: 1, feed_type: 'explore').call

      expect(result[:posts].size).to eq(3)
    end

    it 'does not include posts from user who blocked viewer' do
      user = create(:user)
      user2 = create(:user)
      create_list(:post, 2, :public, user: user)
      create(:post, :public, user: user2)
      user.block!(user2)
      Post.reindex
      create(:user_configuration, user: user2)

      result = Feeds::ExploreService.new(user: user2, page_number: 1, feed_type: 'explore').call

      expect(result[:posts].size).to eq(4)
    end

    it 'order posts with most recent first' do
      user = create(:user)
      create(:user_configuration, user: user)

      4.times do
        create(:post, :public, user: user, publish_date: rand(10).days.ago, publish: true, active: true)
      end

      Post.reindex

      result = Feeds::ExploreService.new(user: user, page_number: 1, feed_type: 'explore').call

      dates = result[:posts].map(&:post).map(&:publish_date)

      expect(dates[0]).to be > dates[1]
      expect(dates[1]).to be > dates[2]
      expect(dates[2]).to be > dates[3]
      expect(dates[3]).to be > dates[4]
    end
  end

  context 'guest user' do
    it 'returns all public posts' do
      Rails.cache.redis.flushall
      result = Feeds::ExploreService.new(user: nil, page_number: 1, feed_type: 'explore').call

      expect(result[:posts].size).to eq(3)
      expect(result[:posts].map(&:post).map(&:view_permission).uniq).to eq([:public])
    end

    it 'order posts with most recent first' do
      Rails.cache.redis.flushall

      result = Feeds::ExploreService.new(user: nil, page_number: 1, feed_type: 'explore').call

      dates = result[:posts].map(&:post).map(&:publish_date)

      expect(dates[0]).to be > dates[1]
      expect(dates[1]).to be > dates[2]
    end
  end

  def prepare_explore_data
    create_list(:post, 3, user: @user)
    create(:post, :followees, user: @user)
    create(:post, :public, user: @user)

    user = create(:user)
    create_list(:post, 2, user: user)
    create_list(:post, 2, :followees, user: user)
    create_list(:post, 2, :public, user: user)
  end
end
