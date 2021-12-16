# frozen_string_literal: true

module Admin
  class ReportUpdateService
    def initialize(report:, notes:, status:, modifier:)
      @report = report
      @notes = notes
      @status = status
      @modifier = modifier
    end

    def call
      update_report
    end

    private

    attr_reader :report, :notes, :status, :modifier

    def update_report
      report.atomically do
        report.update(notes: notes, modifier: modifier) if notes.present?

        if status.present?
          report.update(status: status == 'true', modifier: modifier)

          if report.reportable_type == 'User'
            report.reportable.update(acct_status: status == 'true' ? :active : :restricted)
          else
            report.reportable.update(status: status)
          end
        end
      end
    end
  end
end
