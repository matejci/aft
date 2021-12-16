# frozen_string_literal: true

class AppsController < ApplicationController
  before_action :confirm_admin_logged_in, only: [:index, :update]
  before_action :set_app, only: [:show, :edit, :update]

  def index
    @apps = App.all
  end

  def show; end

  def edit; end

  def update
    respond_to do |format|
      if @app.update(app_params)
        format.html { redirect_to @app, notice: 'App was successfully updated.' }
        format.json { render :show, status: :ok, location: @app }
      else
        format.html { render :edit }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  def configuration
    @configuration = AppConfigurationService.new(app_id: request.headers['APP-ID']).call
  end

  private

  def set_app
    @app = App.find(params[:id])
  end

  def app_params
    params.require(:app).permit(:last_activity, :app_id, :name, :description, :version, :public_key, :key, :secret, :permissions, :access,
                                :requests, :status, :publish, :csrf, :domains, :email, :phone, :user_agent_whitelist,
                                :user_agent_blacklist, :ip_whitelist, :ip_blacklist, :privacy_policy_url, :terms_of_service_url, :namespace, :app_type, supported_versions: [])
  end
end
