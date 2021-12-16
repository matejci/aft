# frozen_string_literal: true

class CommentsController < ApplicationController
  include PostAccessible

  before_action :confirm_user_logged_in, only: [:create, :update, :destroy]
  before_action :set_post, :post_access
  before_action :set_comment, only: [:show, :edit, :update, :destroy, :phantom]
  before_action :check_allowed, only: [:edit, :update, :destroy]

  def index
    @collection = Comments::IndexService.new(user: @current_user, params: params, post: @post).call
  end

  def show; end

  def new
    @comment = @post.comments.new
  end

  def edit; end

  def create
    @comment = @post.comments.new(comment_params.merge(user: @current_user))

    respond_to do |format|
      if @comment.save
        PushNotifications::ProcessorService.new(action: :commented, notifiable: @comment, actor: @current_user, recipient: @comment.post.user).call

        format.html { redirect_to [@comment.post, @comment], notice: 'Comment was successfully created.' }
        format.json { render :show, status: :created, location: [@comment.post, @comment] }
      else
        format.html { render :new }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to [@comment.post, @comment], notice: 'Comment was successfully updated.' }
        format.json { render :show, status: :ok, location: [@comment.post, @comment] }
      else
        format.html { render :edit }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to post_comments_url(@post), notice: 'Comment was successfully destroyed.' }
      format.json { render json: { success: 'Comment destroyed' }, status: :accepted } # format.json { head :no_content }
    end
  end

  def phantom
    if @comment.update!(phantom_by: @current_user)
      render json: { success: 'Phantom accepted' }, status: :accepted
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def check_allowed
    allowed = if action_name == 'destroy'
      @current_user == @comment.user || @current_user == @post.user
    else
      @current_user == @comment.user
    end

    render json: { base: 'Not allowed to modify' }, status: :forbidden unless allowed
  end

  def set_post
    return if (@post = Post.find(params[:post_id]))

    render json: { base: 'Post not found' }, status: :not_found
  end

  def set_comment
    @comment = @post.comments.find_by(id: params[:id])

    render json: { base: 'Comment not found' }, status: :unprocessable_entity unless @comment
  end

  def comment_params
    params.require(:comment).permit(:text, :rich_text, :status, :phantom, :phantom_by, :link, :user_id, :post_id)
  end
end
