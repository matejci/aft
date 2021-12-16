# frozen_string_literal: true

module Admin
  class ReportsService
    PER_PAGE = 10
    REPORT_ENTITIES = %w[Post Comment User].freeze

    def initialize(params:)
      @archived = params[:archived] == 'true'
      @allowed = params[:allowed] == 'true'
      @search_term = params[:search_term]
      @page = params[:page].to_i < 1 ? 1 : params[:page].to_i
      @option = params[:option]
    end

    def call
      return reports if search_term.blank?

      find_reports
    end

    private

    attr_reader :archived, :allowed, :page, :option, :search_term

    def reports
      reports = Report.includes(:reported_by, :reportable)
      reports = reports.where(reportable_type: option) if option.in?(REPORT_ENTITIES)
      reports = reports.where(status: !archived) if allowed != archived
      reports.order(created_at: :desc).page(page).per(PER_PAGE)
    end

    def find_reports
      ids = []
      REPORT_ENTITIES.each { |entity| ids << prepare_ids(entity) }
      ids.flatten!

      report_query(ids)
    end

    def prepare_ids(model_name)
      query = model_name.constantize

      if model_name == 'User'
        query = query.where(completed_signup: true).or(takko_managed: true).where(:acct_status.in => handle_user_statuses)
      elsif allowed != archived
        query = query.where(status: !archived)
      end

      query = query.text_search(search_term) if search_term.present?
      query.pluck(:id)
    end

    def report_query(ids)
      reports = Report.includes(:reported_by, :reportable)

      reports = if option.in?(REPORT_ENTITIES)
        reports.where(reportable_type: option).and(reports.any_of(reports.where(:reportable_id.in => ids),
                                                                  reports.where(:reporters.in => ids),
                                                                  reports.where(:reported_by_id.in => ids),
                                                                  reports.where(reportable_id: search_term),
                                                                  reports.where(id: search_term)))
      else
        reports.where(:reportable_id.in => ids)
               .or(:reporters.in => ids)
               .or(:reported_by_id.in => ids)
               .or(id: search_term)
               .or(reportable_id: search_term)
      end

      reports.order(created_at: :desc).page(page).per(PER_PAGE)
    end

    def reported(relation, ids)
      relation.where(:reported_by_id.in => ids)
    end

    def handle_user_statuses
      if archived && allowed
        %i[restricted active]
      elsif archived
        %i[restricted]
      else
        %i[active]
      end
    end
  end
end
