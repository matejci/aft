# frozen_string_literal: true

class ReportsService
  class ReportError < StandardError; end

  REPORT_ENTITIES = %w[post comment user].freeze

  def initialize(user:, request:, params:)
    @user = user
    @request = request
    @params = params
  end

  def call
    process_report
  rescue StandardError => e
    raise ReportError, e.message
  end

  private

  attr_reader :user, :request, :params

  def process_report
    raise ReportError, 'Unknown entity' unless params[:entity].in?(REPORT_ENTITIES)

    entity = params[:entity].capitalize.constantize.includes(:reports).find_by(params[:identifier] => params[:identifier_value])

    raise ReportError, 'Not found' if entity.blank?

    if entity.reports.any?
      report = entity.reports.first
      report.reporters << user.id
      report.reporters.uniq!
      report.save!
    else
      entity.reports.create!(reported_by: user, request: request, reason: params[:reason], modifier: user)
    end
  end
end
