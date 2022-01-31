# frozen_string_literal: true

class PostsController < ApplicationController
  include PostAccessible

  protect_from_forgery except: :widget

  before_action :set_post, except: [:index, :create, :widget, :show]
  before_action :post_access, only: [:report, :upvote, :downvote, :takkos]
  before_action :check_owner, only: [:edit, :update, :destroy]
  before_action :confirm_user_logged_in, except: [:index, :show, :embed, :takkos, :report, :widget]
  after_action  :allow_iframe, only: :embed

  def index
    @posts = Post.active.order_by([:created_at, :desc]).page(params[:page].presence || 1).per(params[:limit].presence || 20)
  end

  def show
    identifier = params[:id].presence || params[:link].presence

    @post = Posts::ShowPostService.new(identifier: identifier, viewer: @current_user).call

    respond_to do |format|
      if @post.nil?
        format.json { render json: { base: 'Post is not available' }, status: :forbidden }
        format.html { render text: 'Post not available' }
      else
        format.json { render partial: 'posts/custom_posts/custom_item', locals: { custom_post: @post } }
        format.html
      end
    end
  end

  def embed; end

  def takkos
    @collection = Posts::TakkosService.new(post: @post, params: params.slice(:order, :page, :per_page)).call
  end

  def edit; end

  def create
    @post = Posts::CreatePostService.new(user: @current_user, params: post_params).call

    respond_to do |format|
      if @post.errors.any?
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      else
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render partial: 'posts/preview', locals: { post: @post }, status: :created }
      end
    end
  end

  def update
    render json: { errors: @post.errors } , status: :unprocessable_entity and return unless @post.update(post_params)
  end

  def destroy
    post = Posts::DeletePostService.new(post: @post, with_takkos: params[:with_takkos]).call

    if post[:errors].any?
      render json: post[:errors].full_messages, status: :unprocessable_entity
    else
      respond_to do |format|
        format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def report
    report = @post.reports.new(reported_by: @current_user, request: request, modifier: @current_user)
    if report.save
      render json: { success: 'Thank you for reporting' }, status: :ok
    else
      render json: report.errors, status: :unprocessable_entity
    end
  end

  def upvote
    respond_to :json

    upvote = Upvote.toggle(@post, @current_user)
    PushNotifications::ProcessorService.new(action: :upvoted, notifiable: @post, actor: @current_user, recipient: @post.user).call if upvote.is_a?(Upvote)

    render :vote
  end

  # Obsolete, but let's keep it for now...
  def downvote
    respond_to :json

    Downvote.toggle(@post, @current_user)
    render :vote
  end

  def widget
    respond_to :js
  end

  private

  def set_post
    return if (@post = params[:link] ? Post.active.find_by(link: params[:link]) : Post.active.find(params[:id]))

    # guard for web requests
    if web_request?
      redirect_to root_url
    else
      render json: { base: 'Post not found' }, status: :not_found
    end
  end

  def check_owner
    return if @post.owner?(@current_user)

    # status unauthorized is for authentication, forbidden for action authorization
    render json: { base: 'Not allowed to modify' }, status: :forbidden
  end

  def post_params
    params.require(:post).permit(
      :parent_id, :category_id, :title, :description, :media_file, :media_type,
      :media_thumbnail, :allow_comments, :view_permission, :takko_permission,
      :takko_order, :video_length, :publish, :link_title, :animated_cover, :animated_cover_offset,
      viewer_ids: [], viewer_group_ids: [], takkoer_ids: [], takkoer_group_ids: []
    ).merge(params.permit(:media_file, :media_thumbnail)) # for iOS multipart request
  end
end
