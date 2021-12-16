# frozen_string_literal: true

class ViewLoggerJob < ApplicationJob
  queue_as :view_logger_jobs
  sidekiq_options retry: 2

  def perform(view_tracking_id, last_event_index, event_index)
    return unless (@view_tracking = ViewTracking.find(view_tracking_id))

    return if (last_event_index + 1) == event_index # nothing to log

    events = @view_tracking.event_timestamps[(last_event_index + 1)..event_index]
    return unless (start_index = find_last_played_idx(events)) # no played event

    begin
      events = events[start_index..event_index]
      play_events = %w[started resumed buffering_ended]
      stop_events = %w[paused ended buffering_started]
      progress = 0

      prev_status, prev_time = []
      curr_status, curr_time = events[0].first

      events[1..-1].each_with_index do |e, _i|
        # example: e = { started: Thu, 20 Aug 2020 12:00:01 PDT -07:00 }

        prev_status, prev_time = curr_status, curr_time
        curr_status, curr_time = e.first

        if play_events.include?(prev_status) && stop_events.include?(curr_status)
          # add played time to progress
          progress += curr_time - prev_time
        end
      end

      @view_tracking.progress = progress

      if @view_tracking.valid_progress?
        @view_tracking.start_time = events[0].values.first
        @view_tracking.end_time   = events[-1].values.first

        @view_tracking.views.create!
        @view_tracking.watch_times.create! if @view_tracking.watch_time_eligible?

        elapsed_time = Time.current - @view_tracking.start_time

        if (elapsed_time / 1.hour) > 1
          Bugsnag.notify('late view logging detected') do |report|
            report.severity = 'warning'
            report.add_tab(
              :view_tracking,
              view_tracking.bugsnag_attributes.merge(
                elapsed_time_in_minutes: elapsed_time / 1.minute
              )
            )
          end
        end
      end
    rescue StandardError => e
      Bugsnag.notify(e)

      if e.is_a?(Mongoid::Errors::Validations)
        e.record.notify_bugsnag(e)
      elsif @view_tracking
        @view_tracking.notify_bugsnag(e)
      end
    end
  end

  def find_last_played_idx(arr)
    # check for last start event since start ignores previous events
    reversed = arr.reverse
    idx = reversed.find_index { |e| e.keys.first == 'started' }

    # if no start event was found, check for resume/buffering_end
    idx ||= reversed.find_index do |e|
      %w[resumed buffering_ended].include?(e.keys.first)
    end

    idx ? (arr.size - 1 - idx) : nil
  end
end
