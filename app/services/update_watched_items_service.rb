# frozen_string_literal: true

class UpdateWatchedItemsService
  MIN_WATCH_PERIOD = 1.0 # seconds

  def initialize(post_id:, view_tracking:, user:)
    @post_id = post_id
    @view_tracking = view_tracking
    @user = user
  end

  def call
    update_watched_items
  end

  private

  attr_reader :post_id, :view_tracking, :user

  def update_watched_items
    event_timestamps = view_tracking.event_timestamps.select { |et| et.values[0] > last_restart }

    return unless last_activity_valid? && minimum_watch_period?(event_timestamps)

    user.configuration.watched_items << post_id
    user.configuration.save!
  end

  def minimum_watch_period?(event_timestamps)
    (event_timestamps[1].values[0] - view_tracking.event_timestamps[0].values[0]) >= MIN_WATCH_PERIOD
  end

  def last_activity_valid?
    view_tracking.last_activity.utc > last_restart
  end

  def last_restart
    @last_restart ||= DateTime.now.utc.beginning_of_week.advance(hours: 12)
  end
end
