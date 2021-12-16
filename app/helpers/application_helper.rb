# frozen_string_literal: true

module ApplicationHelper
  def report_type(report_item)
    type = report_item.reportable_type
    type = 'Takko' if type == 'Post' && !report_item.reportable.try(:parent_id).nil?
    type
  end

  def reporters_count(report_item)
    html_string = []
    html_string << report_item.reported_by.username
    html_string << "+ #{report_item.reporters.size} more" if report_item.reporters.any?
    html_string.join(' ')
  end

  def reporters(report_item)
    reporters = User.find(report_item.reporters)

    html_string = []

    reporters.each do |reporter|
      if html_string.empty?
        html_string << "<span class='details_text reporters_text'>#{reporter.username}</span>"
      else
        html_string << "<span class='details_text reporters_text'>+ #{report_item.reporters.size - html_string.size} more"
        break
      end
    end

    html_string.join('<br/>')
  end

  def username(report_item)
    report_item.reportable.is_a?(User) ? report_item.reportable.username : report_item.reportable.user.username
  end

  def history_content(report_item)
    history_arr = []

    report_item.history_tracks.includes(:modifier).each do |ht|
      next history_arr << "<b>#{ht.modifier.username}</b> @ #{ht.created_at.strftime('%Y-%m-%d %H:%M')} - created report." if ht.action == 'create'

      history_arr << "<b>#{ht.modifier.username}</b> @ #{ht.created_at.strftime('%Y-%m-%d %H:%M')} updated report with changes:<br/>#{parse_history_changes(ht.modified)}"
    end

    history_arr.join('<hr/>')
  end

  private

  def parse_history_changes(changes)
    results = []

    changes.each do |k, v|
      results << "#{k}: #{v}"
    end

    results.join('<br/>')
  end
end
