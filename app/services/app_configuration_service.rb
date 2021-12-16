# frozen_string_literal: true

class AppConfigurationService
  def initialize(app_id:)
    @app_id = app_id
  end

  def call
    configuration
  end

  private

  attr_reader :app_id

  def configuration
    app = App.includes(:configuration).find_by(app_id: app_id)
    app.configuration
  end
end
