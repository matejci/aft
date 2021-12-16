# frozen_string_literal: true

class IosConfigService
  def initialize; end

  def call
    ios_config
  end

  private

  def ios_config
    app = App.includes(:configuration).find_by(app_type: :ios)
    app.configuration
  end
end
