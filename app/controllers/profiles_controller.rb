# frozen_string_literal: true

class ProfilesController < ApplicationController
  # NOTE: order matters. should not alphabetize
  before_action :check_current_user, except: [:show, :feed, :posts, :user]
  before_action :set_user
  before_action :set_viewer, only: [:show, :feed, :user]
  before_action :check_blocked_user, except: [:block, :unblock]

  def show; end

  def feed
    respond_to do |format|
      format.html
      format.json
    end
  end

  def user
    @creator_program = CreatorProgram.last
    render partial: 'profiles/user', object: @user
  end

  def posts
    render json: { base: 'No user session' }, status: :unprocessable_entity and return if params[:posts] == 'private' && @current_user.nil?

    @collection = Feeds::ProfileService.new(posts_type: params[:posts],
                                            user: @user,
                                            viewer: @current_user,
                                            order: params[:order],
                                            page: params[:page]).call
  end

  def block
    block = @current_user.block!(@user)

    if block.persisted?
      render json: { success: 'This account has been blocked' }, status: :created
    else
      render json: block.errors, status: :unprocessable_entity
    end
  end

  def unblock
    @current_user.unblock!(@user)
    render json: {}, status: :ok
  end

  def follow
    follow = @current_user.follow!(@user)

    if follow.persisted?
      PushNotifications::ProcessorService.new(action: :followed, notifiable: follow, actor: @current_user, recipient: follow.followee).call

      render json: {}, status: :created
    else
      render json: follow.errors, status: :unprocessable_entity
    end
  end

  def followees
    @followees = FollowingsService.new(user: @user, page: params[:page], follow_type: :followee).call
  end

  def followers
    @followers = FollowingsService.new(user: @user, page: params[:page], follow_type: :follower).call
  end

  def unfollow
    @current_user.unfollow!(@user)
    render json: { status: :ok }
  end

  def report
    report = @user.reports.new(reported_by: @current_user, request: request, modifier: @current_user)

    if report.save
      render json: { success: 'Thank you for reporting' }, status: :ok
    else
      render json: report.errors, status: :unprocessable_entity
    end
  end

  private

  def check_blocked_user
    return unless @user.blocked?(@current_user)

    render json: { base: 'User has limited your viewing access' }, status: :forbidden
  end

  def check_current_user
    return if @current_user

    render json: { base: 'No user session' }, status: :unprocessable_entity
  end

  def set_user
    username_regex = /^#{params[:username]}$/i

    return if (@user = User.active.find_by(username: username_regex))

    # guard for web requests
    if web_request?
      redirect_to root_url
    else
      render json: { base: 'Profile user not found' }, status: :unprocessable_entity
    end
  end

  def set_viewer
    @viewer = @current_user
  end
end
