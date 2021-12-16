# frozen_string_literal: true

class ViewsController < ApplicationController
  before_action :confirm_session_exists
  before_action :set_filter_variables, only: [:data, :events_data]

  def data
    if @post.present?
      render 'post_data.json.jbuilder'
    else
      render 'user_data.json.jbuilder'
    end
  end

  def events_data
    @viewer = User.find(params[:viewer_id]) if params[:viewer_id]
    @views = @views.where(viewed_by: @viewer)
    @view_trackings = ViewTracking.includes(:session).where(post: @post, user: @viewer)
  end

  def event
    current_time = Time.current # mark current time first for more accurate timestamp
    post = Post.find_by(link: params[:p_link])

    if post
      view_tracking = ViewTracking.init_with(@current_session, post)

      if view_tracking.nil?
        Bugsnag.leave_breadcrumb("view_tracking: #{view_tracking}")
        view_tracking = ViewTracking.find_by(post: post, session: @current_session)
        Bugsnag.leave_breadcrumb("view_tracking find_by: #{view_tracking&.id}")
        Bugsnag.notify('view tracking is nil again...!!!')
      end

      view_tracking.event = params[:event]
      view_tracking.source = params[:source]
      view_tracking.current_time = current_time
      view_tracking.record

      UpdateWatchedItemsService.new(post_id: post.id, view_tracking: view_tracking, user: @current_session.user).call if update_watched_items?

      head :ok
    else
      render json: { base: 'Post not found' }, status: :not_found
    end
  end

  private

  def confirm_session_exists
    return true if @current_session

    render json: { base: 'no session exists' }, status: :unauthorized
  end

  def set_filter_variables
    @user = User.find(params[:user_id])
    @date = params[:date].to_date
    @views = @user.views.where(date: @date)
    @watch_times = @user.watch_times.where(date: @date)

    return unless params[:post_id]

    @post = @user.posts.find(params[:post_id])
    @views = @views.where(post: @post)
    @watch_times = @watch_times.where(post: @post)
  end

  def update_watched_items?
    params[:source] == 'discoverFeed' && params[:event] != 'start' && @current_session.user
  end
end
