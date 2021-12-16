# frozen_string_literal: true

class ReportErrorService
  def initialize(name:, data: {})
    @name = name
    @data = data
  end

  def call
    report_error
  end

  private

  attr_reader :name, :data

  def report_error
    error_details = format_data

    Bugsnag.notify(name) do |report|
      report.severity = 'error'
      error_details.each { |key, value| report.add_tab(key, value) }
    end

    AdminMailer.with(name: name, data: error_details).report_error.deliver_now
  end

  def format_data
    formatted = data.each_with_object({}) do |(key, value), hash|
      hash[key] = if key == :response
        { class: value.class, code: value.code, body: JSON.parse(value.body) }
      else
        value
      end
    end

    formatted[:time] = Time.current unless formatted.key?(:time)
    formatted
  end
end
