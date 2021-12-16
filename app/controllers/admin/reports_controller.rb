# frozen_string_literal: true

module Admin
  class ReportsController < ApplicationController
    before_action :confirm_admin_logged_in
    before_action :set_report, only: [:show, :update]

    def index
      @collection = Admin::ReportsService.new(params: params).call
    end

    def show; end

    def update
      Admin::ReportUpdateService.new(report: @report, notes: params[:notes], status: params[:allowed], modifier: @current_user).call
    end

    private

    def set_report
      @report = Report.includes(:reported_by, :reportable).find(params[:id])
    end
  end
end
