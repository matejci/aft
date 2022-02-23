# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Leaderboard::Posts' do
  include_context 'authenticated request', user_session: true

  explanation <<~DOC
    - `period` param valid values are: 'all_time', 'weekly', 'monthly'
    - if `period` param is not specified, endpoints will fallback to 'all_time'
  DOC

  header 'X-API-VERSION', 'api.appforteachers.v1'

  parameter :period, type: :string, required: false

  let!(:post_list) { create_list(:post, 10, :public) }
  let!(:user_configuration) { create(:user_configuration, user: user) }

  before do
    Rails.cache.clear
  end

  #-------------------------------- POSTS --------------------------------

  route '/leaderboard/posts/takkos.json', 'get posts with most received takkos' do
    get 'posts - most takkos received' do
      context 'all time' do
        before { create_takkos }

        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_takkos')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(4)
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { create_takkos('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_takkos')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(3)
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { create_takkos('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_takkos')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(2)
        end
      end
    end
  end

  route '/leaderboard/posts/upvoted.json', 'get most upvoted posts' do
    get 'posts - most upvoted' do
      context 'all time' do
        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_upvoted')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(10)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'upvotes_count')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'upvotes_count')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { update_posts_publish_date('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_upvoted')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(3)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'upvotes_count')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'upvotes_count')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { update_posts_publish_date('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_upvoted')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(2)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'upvotes_count')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'upvotes_count')
        end
      end
    end
  end

  route '/leaderboard/posts/discussed.json', 'get most discussed posts' do
    get 'posts - most discussed' do
      context 'all time' do
        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_discussed')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(10)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'comments_count')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'comments_count')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { update_posts_publish_date('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_discussed')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(3)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'comments_count')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'comments_count')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { update_posts_publish_date('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_discussed')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(2)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'comments_count')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'comments_count')
        end
      end
    end
  end

  route '/leaderboard/posts/viewed.json', 'get most viewed posts' do
    get 'posts - most viewed' do
      context 'all time' do
        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_viewed')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(10)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'counted_watchtime')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'counted_watchtime')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { update_posts_publish_date('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_viewed')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(3)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'counted_watchtime')).to be > parsed_response.dig('data', 1, 'item', 'items', 0, 'counted_watchtime')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { update_posts_publish_date('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response).to include('type' => 'leaderboard_posts_viewed')
          expect(parsed_response).to include('total_pages' => 1)
          expect(parsed_response['data']).to be_an_instance_of(Array)
          expect(parsed_response['data'].size).to eq(2)
          expect(parsed_response.dig('data', 0, 'item', 'items', 0, 'counted_watchtime')).to be >= parsed_response.dig('data', 1, 'item', 'items', 0, 'counted_watchtime')
        end
      end
    end
  end
  #------------------------------------------------------------------------

  #-------------------------------- USERS --------------------------------
  route '/leaderboard/users/viewed.json', 'get most viewed users' do
    get 'users - most viewed' do
      context 'all time' do
        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(11)
          expect(parsed_response['users'].dig(0, 'counted_watchtime')).to be > parsed_response['users'].dig(1, 'counted_watchtime')
          expect(parsed_response['users'].dig(4, 'counted_watchtime')).to be > parsed_response['users'].dig(8, 'counted_watchtime')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { prepare_watchtimes('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(3)
          expect(parsed_response['users'].dig(0, 'counted_watchtime')).to be >= parsed_response['users'].dig(1, 'counted_watchtime')
          expect(parsed_response['users'].dig(1, 'counted_watchtime')).to be >= parsed_response['users'].dig(2, 'counted_watchtime')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { prepare_watchtimes('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'counted_watchtime')).to be > parsed_response['users'].dig(1, 'counted_watchtime')
        end
      end
    end
  end

  route '/leaderboard/users/discussed.json', 'get most discussed users' do
    get 'users - most discussed' do
      context 'all time' do
        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(11)
          expect(parsed_response['users'].dig(0, 'comments_count')).to be >= parsed_response['users'].dig(1, 'comments_count')
          expect(parsed_response['users'].dig(4, 'comments_count')).to be >= parsed_response['users'].dig(8, 'comments_count')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { prepare_comments('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'comments_count')).to be > parsed_response['users'].dig(1, 'comments_count')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { prepare_comments('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'comments_count')).to be > parsed_response['users'].dig(1, 'comments_count')
        end
      end
    end
  end

  route '/leaderboard/users/followed.json', 'get most followed users' do
    get 'users - most followed' do
      context 'all time' do
        before do
          users = User.all.to_a

          users.each_with_index do |user, ind|
            user.follow!(users[1]) if ind % 3 == 0
          end

          users[0].follow!(users[2])
        end

        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(11)
          expect(parsed_response['users'].dig(0, 'followers_count')).to be > parsed_response['users'].dig(1, 'followers_count')
          expect(parsed_response['users'].dig(1, 'followers_count')).to be > parsed_response['users'].dig(2, 'followers_count')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { prepare_follows('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'followers_count')).to be > parsed_response['users'].dig(1, 'followers_count')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { prepare_follows('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'followers_count')).to be > parsed_response['users'].dig(1, 'followers_count')
        end
      end
    end
  end

  route '/leaderboard/users/takkos.json', 'get users with most takkos received' do
    get 'users - most takkos received' do
      context 'all time' do
        before { create_takkos }

        example_request '200 - all_time' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'takkos_received')).to be > parsed_response['users'].dig(1, 'takkos_received')
        end
      end

      context 'weekly' do
        let(:period) { 'weekly' }

        before { create_takkos('weekly') }

        example_request '200 - weekly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'takkos_received')).to be > parsed_response['users'].dig(1, 'takkos_received')
        end
      end

      context 'monthly' do
        let(:period) { 'monthly' }

        before { create_takkos('monthly') }

        example_request '200 - monthly' do
          expect(status).to eq(200)
          expect(parsed_response.keys).to include('users')
          expect(parsed_response['users']).to be_an_instance_of(Array)
          expect(parsed_response['users'].size).to eq(2)
          expect(parsed_response['users'].dig(0, 'takkos_received')).to be > parsed_response['users'].dig(1, 'takkos_received')
        end
      end
    end
  end
  #------------------------------------------------------------------------

  def create_takkos(period = nil)
    post_list.each_with_index do |post, ind|
      next unless ind % 3 == 0

      takkos = create_list(:post, 3, :public)
      takkos.each_with_index do |takko, t_ind|
        takko.set(parent_id: post.id,
                  original_user_id: t_ind.even? ? post_list[0].user.id : post_list[1].user.id,
                  active: true,
                  own_takko: false,
                  publish_date: resolve_publish_date(period, ind))
      end
    end
  end

  def update_posts_publish_date(period)
    Post.update_all(publish_date: 3.months.ago)

    post_list.each_with_index do |post, ind|
      next unless ind % 3 == 0

      post.set(publish_date: resolve_publish_date(period, ind))
    end
  end

  def resolve_publish_date(period, ind)
    if period == 'weekly'
      Time.zone.today - ind.days
    else
      Time.zone.today - ind.weeks
    end
  end

  def prepare_watchtimes(period)
    post_list.each_with_index do |post, ind|
      next unless ind % 3 == 0

      started_at = Time.current
      wt = WatchTime.new(user_id: post.user.id,
                         counted: true,
                         started_at: started_at,
                         ended_at: started_at + rand(3..30).seconds,
                         watched_by_id: post_list[rand(0..9)].user.id,
                         created_at: resolve_publish_date(period, ind),
                         total: rand(3..30))

      wt.save(validate: false)
    end
  end

  def prepare_comments(period)
    post_list.each_with_index do |_post, ind|
      user = ind % 3 == 0 ? post_list[0].user : post_list[1].user

      create(:comment, user: user, created_at: resolve_publish_date(period, ind))
    end
  end

  def prepare_follows(period)
    post_list.each_with_index do |_post, ind|
      if ind % 3 == 0
        Follow.create(followee_id: post_list[0].user.id, follower_id: post_list[ind].user.id, created_at: resolve_publish_date(period, ind))
      else
        Follow.create(followee_id: post_list[1].user.id, follower_id: post_list[ind].user.id, created_at: resolve_publish_date(period, ind))
      end
    end
  end
end
