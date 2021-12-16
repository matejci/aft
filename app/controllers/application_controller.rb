# frozen_string_literal: true

require 'jwt'

class ApplicationController < ActionController::Base
  include ErrorHandling

  protect_from_forgery with: :null_session

  before_action :web_app_token_init, if: :web_request?
  before_action :validate_app_token, unless: :known_agents
  before_action :set_current_user, unless: :known_agents

  private

  def web_request?
    request.format.html? || request.format.js?
  end

  def web_app_token_init
    return if request.headers['APP-ID'] && request.headers['HTTP-X-APP-TOKEN']

    payload = {
      app_id: ENV['APP_ID'],
      public_key: ENV['APP_PUBLIC_KEY']
    }

    user_agent = request.user_agent
    token = JWT.encode(payload, ENV['APP_SECRET'] + user_agent, 'HS512')

    request.headers['HTTP-X-APP-TOKEN'] = token
    request.headers['APP-ID'] = ENV['APP_ID']
  end

  def validate_app_token
    @app_token_validation = AppTokenValidationService.new(request: request).call
  end

  def set_current_user
    # TODO; remove Rails session - send access_token from both Web and Mobile clients
    session[:user_token] = request.headers['HTTP-ACCESS-TOKEN'] if !@app_token_validation[:app].web? || request.headers.include?('HTTP-ACCESS-TOKEN')

    return guest_session if session[:user_token].blank?

    user_session = Sessions::SessionValidationService.new(token: session[:user_token], request: request).call

    # QUESTION: should we mark or block invalid token?
    if user_session[:success] == false
      session.delete(:user_token)
      raise ActionController::BadRequest, user_session[:base]
    else
      @current_session = user_session
      @current_user = user_session.user
      response.set_header('UNREAD-NOTIFICATIONS-COUNT', @current_user.unread_notifications_count)
    end
  end

  def guest_session
    @current_user, @current_session = Sessions::GuestSessionService.new(request: request, app_token_validation: @app_token_validation)
                                                                   .call
                                                                   .values_at(:current_user, :current_session)
  end

  def confirm_user_logged_in
    return if  @current_user&.active_account?

    respond_to do |format|
      format.html do
        flash[:notice] = @current_user.nil? ? 'Please log in.' : I18n.t('errors.deactivated_acct')

        redirect_to login_path
      end

      format.json do
        render json: { base: @current_user.nil? ? 'No user session' : I18n.t('errors.deactivated_acct') },
               status: :unauthorized
      end
    end
  end

  def confirm_admin_logged_in
    return if @current_user&.admin?

    redirect_to root_url and return if @current_user

    flash[:notice] = 'Please log in.'
    redirect_to root_url
  end

  def prepare_session(user, admin_login = nil)
    @current_user = user

    # new session JWT token with payload
    @current_session = Sessions::SessionAuthService.new(request: request, user: user, app_token_validation: @app_token_validation, admin_login: admin_login).call
    session[:user_token] = @current_session.token
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def known_agents
    @known_agents ||= KNOWN_USER_AGENTS.find { |ua| request.user_agent.include?(ua) }
  end
end
