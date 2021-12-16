# frozen_string_literal: true

module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from ActionController::UnknownFormat, with: :bad_request
    rescue_from ActionController::BadRequest, with: :bad_request
    rescue_from UncaughtThrowError, with: :bad_request
    rescue_from AppTokenValidationService::AppVersionError, with: :version_error
    rescue_from AppTokenValidationService::AppError, with: :unprocessable_entity
    rescue_from Leaderboard::BaseService::LeaderboardError, with: :bad_request
    rescue_from Creatorprogram::OptInService::ThresholdReachedError, with: :bad_request
    rescue_from Creatorprogram::OptInService::CreatorProgramInactive, with: :bad_request
    rescue_from Creatorprogram::OptInService::UserNotFound, with: :bad_request
    rescue_from Search::BaseService::SearchParamMissing, with: :bad_request
    rescue_from Search::BaseService::SearchParamTooShort, with: :bad_request
    rescue_from ReportsService::ReportError, with: :bad_request
    rescue_from Mongoid::Errors::Validations, with: :bad_request
  end

  private

  def bad_request(exception)
    handle_web_error(exception) and return unless request.format.json?

    render json: { error: exception.message }, status: :bad_request
  end

  def version_error(response)
    render json: response.response_object, status: 418
  end

  def unprocessable_entity(response)
    render json: response.response_object, status: :unprocessable_entity
  end

  def handle_web_error(exception)
    render plain: exception.message
  end
end
