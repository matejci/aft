# frozen_string_literal: true

require 'rails_helper'

describe Feeds::HomeService do
  before(:each) do
    create(:category, :tutorial)
    @user = create(:user)
    @viewer = create(:user)
    prepare_data
    Post.reindex
  end

  it 'returns all posts from user' do
    create(:user_configuration, user: @user)
    result = service_call(@user)
    expect(result[:posts].size).to eq(5)
  end

  it 'returns public posts from followee' do
    @viewer.follow!(@user)
    create(:user_configuration, user: @viewer)
    result = service_call(@viewer)

    expect(result[:posts].size).to eq(1)
  end

  it 'includes public and followees posts from mutual follow' do
    other_user = create(:user)
    other_user.follow!(@user)
    @user.follow!(other_user)
    Post.reindex
    create(:user_configuration, user: other_user)

    result = service_call(other_user)
    expect(result[:posts].size).to eq(2)
  end

  it 'does not include any post from non-followees' do
    user = create(:user)
    create(:user_configuration, user: user)

    result = service_call(user)
    expect(result).to be_nil
  end

  it 'returns nil if there is no results - guest mode' do
    result = service_call(nil)
    expect(result).to eq(nil)
  end

  it 'order posts with most recent first' do
    user = create(:user)
    create(:user_configuration, user: user)

    4.times do
      create(:post, user: user, publish_date: rand(10).days.ago, publish: true, active: true)
    end

    Post.reindex

    result = service_call(user)

    dates = result[:posts].map(&:post).map(&:publish_date)

    expect(dates[0]).to be > dates[1]
    expect(dates[1]).to be > dates[2]
  end

  def service_call(user)
    Feeds::HomeService.new(user: user, page_number: 1, feed_type: 'home').call
  end

  def prepare_data
    create_list(:post, 3, user: @user)
    create(:post, :followees, user: @user)
    create(:post, :public, user: @user)
  end
end
