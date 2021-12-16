# frozen_string_literal: true

class UserConfigurationsController < ApplicationController
  before_action :confirm_user_logged_in, only: :update
  before_action :set_config

  def show; end

  def update
    UpdateUserConfigurationService.new(config: @config, params: config_params).call
    head :ok
  end

  private

  def set_config
    @config = if @current_user
      @current_user.configuration
    else
      AppConfigurationService.new(app_id: request.headers['APP-ID']).call
    end
  end

  def config_params
    params.require(:user_configuration).permit(:app_tracking_transparency,
                                               ads: [:search_ads_enabled, :search_ads_frequency, :discover_ads_enabled, :discover_ads_frequency])
  end
end
