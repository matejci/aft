# frozen_string_literal: true

class UpdateUserConfigurationService
  def initialize(config:, params:)
    @config = config
    @params = params
  end

  def call
    update_config
  end

  private

  attr_reader :config, :params

  def update_config
    if params[:app_tracking_transparency].present?
      config.app_tracking_transparency = params[:app_tracking_transparency]
      config.app_tracking_transparency_recorded_at = Time.current
    end

    params[:ads].each { |k, v| config.ads[k] = v } if params[:ads].present?

    config.save!
  end
end
