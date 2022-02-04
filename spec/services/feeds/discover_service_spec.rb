# frozen_string_literal: true

require 'rails_helper'

describe Feeds::DiscoverService do
  before(:each) do
    create(:category, :tutorial)
    @user = create(:user)
    @viewer = create(:user)
    @app = App.first
    curated_posts
    prepare_data
  end

  it 'does not return posts from blocked user' do
    user = create(:user)
    create(:user_configuration, user: user, watched_items: [])
    session = create(:session, user: user)

    user.block!(@user)

    result = service_call(session)

    expect(result[:posts].size).to eq(1)
  end

  it 'does not return posts from user who blocked viewer' do
    user = create(:user)
    create(:user_configuration, user: user, watched_items: [])
    session = create(:session, user: user)

    @another_user.block!(user)

    result = service_call(session)
    expect(result[:posts].size).to eq(2)
  end

  it 'returns unwatched curated videos' do
    user = create(:user)
    create(:user_configuration, user: user, watched_items: [])
    session = create(:session, user: user)

    result = service_call(session)
    expect(result[:posts].size).to eq(3)
  end

  it 'returns empty array if user watched all curated posts' do
    user = create(:user)
    create(:user_configuration, user: user, watched_items: Post.where(description: 'CURATED_POST').pluck(:id))
    session = create(:session, user: user)

    result = service_call(session)
    expect(result[:posts].size).to eq(0)
  end

  def prepare_data
    create(:post, user: @user)
    create(:post, :followees, user: @user)
    create(:post, :public, user: @user)
  end

  def curated_posts
    curated_posts = create_list(:post, 2, :public, user: @user, description: 'CURATED_POST').pluck(:id)
    @another_user = create(:user)
    curated_posts << create_list(:post, 1, :public, user: @another_user, description: 'CURATED_POST').pluck(:id)

    conf = @app.create_configuration
    conf.curated_posts << curated_posts
    conf.curated_posts.flatten!
    conf.save
  end

  def service_call(session)
    Feeds::DiscoverService.new(session: session, page_number: 1, app_id: @app.app_id).call
  end
end
