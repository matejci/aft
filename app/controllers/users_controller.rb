# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :confirm_admin_logged_in, only: [:index, :show, :destroy]
  before_action :confirm_user_logged_in, only: [:show, :blocked_accounts, :remove_account]
  before_action :set_user, only: [:show, :update, :destroy]

  def authenticate
    if @current_user
      if @current_user.authenticate(user_params[:password])
        render json: { success: 'Authenticated' }, status: :ok
      else
        render json: @current_user.errors, status: :unprocessable_entity
      end
    else
      render json: { base: 'No user session' }, status: :unprocessable_entity
    end
  end

  def blocked_accounts
    @blocked_users = @current_user.blocked_users.page(params[:page]).per(36)
  end

  def current_user_session
    respond_to do |format|
      if @current_user
        format.json { render @current_user, status: :created, location: @current_user }
      else
        format.json { render json: { base: 'no current user session' }, status: :unprocessable_entity }
      end
    end
  end

  # send_sms_code
  def phone_verification
    respond_to do |format|
      if @current_user
        # TODO: move validation to model
        if @current_user.phone.present?
          # send phone verification
          if @current_user.send_phone_verification(save: true)
            format.json { render json: { success: 'Phone verification sent' }, status: :ok }
          else
            format.json { render json: @current_user.errors, status: :unprocessable_entity }
          end
        else
          format.json { render json: { phone: 'no phone number' }, status: :unprocessable_entity }
        end
      else
        format.json { render json: { base: 'no current user session' }, status: :unprocessable_entity }
      end
    end
  end

  def index
    @users = User.all
  end

  def show; end

  def new
    respond_to :html

    if @current_user
      flash[:notice] = 'You are already signed in!'
      redirect_to root_url
    end

    @user = User.new
  end

  def edit
    respond_to :html
  end

  def create
    respond_to :json

    sign_up = UserUpdateService.new(user: User.new, params: user_params.merge(ip_address: request.remote_ip, user_agent: request.user_agent)).call

    if sign_up[:success]
      user = sign_up[:user]
      prepare_user_configuration(user)
      prepare_session(user)

      render user, status: :created, location: user
    else
      render json: sign_up[:errors], status: :unprocessable_entity
    end
  end

  def update
    respond_to :json

    render json: { base: 'No user session' }, status: :unauthorized and return if @current_user.nil?

    # TODO, move this functionality to SignupController
    sign_up = UserUpdateService.new(user: @current_user, params: user_params).call

    if sign_up[:success]
      render sign_up[:user], status: :ok
    else
      render json: sign_up[:errors], status: :unprocessable_entity
    end
  end

  def destroy
    # NOTE: for ios testing purposes only
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  rescue Mongoid::Errors::DeleteRestriction => e
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end

  def remove_account
    remove_acct = RemoveAccountService.new(
      user: @current_user, password: params[:password],
      remote_ip: request.remote_ip, user_agent: request.user_agent
    ).call

    if remove_acct[:success]
      render json: { status: 'success', message: 'account has been deactivated' }
    else
      render json: { status: 'error', errors: remove_acct[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = params[:id] ? User.find(params[:id]) : @current_user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :username, :display_name,
                                 :bio, :birthdate, :website, :email, :new_email, :phone, :new_phone,
                                 :password, :new_password, :new_password_confirmation,
                                 :invite, :tos_acceptance, :phone_code, :email_code,
                                 :profile_image, :background_image)
  end

  def prepare_user_configuration(user)
    Users::ConfigurationInitService.new(user: user).call
  end
end
