# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :confirm_admin_logged_in, only: :index if Rails.env.production?

  def index
    @sessions = Session.all.order_by(%i[created_at desc]).page(params[:page]).per(params[:limit])

    respond_to do |format|
      format.html { redirect_to '/admin/sessions', notice: 'Welcome to Admin Panel' }
      format.json { render :index, status: :ok }
    end
  end

  def new
    if @current_user
      flash[:notice] = 'You are already signed in!'
      redirect_to root_url
    end

    @form = {
      action: sessions_path,
      csrf_param: request_forgery_protection_token,
      csrf_token: form_authenticity_token
    }
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    auth = UserAuthService.new(id: user_params[:id], password: user_params[:password], app: @app_token_validation[:app]).call

    if auth[:success]
      user = auth[:user]
      prepare_session(user, auth[:admin_login])
      render user, status: :created
    else
      render json: auth[:errors] || { base: auth[:message] }, status: :unprocessable_entity
    end
  end

  def destroy
    @current_session&.update(live: false)
    session.delete(:user_token)

    respond_to do |format|
      format.html do
        flash[:notice] = 'Logged out!'
        redirect_to root_url
      end

      format.json do
        render json: { status: 'signed out' }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:id, :password)
  end
end
