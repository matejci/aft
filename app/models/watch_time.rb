# frozen_string_literal: true

class WatchTime
  include Mongoid::Document
  include Mongoid::Timestamps
  has_and_belongs_to_many :pools
  has_and_belongs_to_many :pool_intervals

  belongs_to :post
  belongs_to :user, index: true
  belongs_to :view_tracking
  belongs_to :watched_by, class_name: 'User', optional: true

  # view tracking constants
  field :minimum_view, type: Integer

  field :started_at, type: DateTime
  field :ended_at,   type: DateTime
  field :date,       type: Date

  field :counted, type: Boolean
  field :total,   type: Float

  before_validation :initialize_from_view_tracking, if: :new_record?

  before_create :set_date

  validates :started_at, :ended_at, presence: true
  validates :started_at, uniqueness: { scope: :view_tracking_id }
  validate  :correct_event_timestamps
  validate  :watch_time_eligible

  scope :counted, -> { where(counted: true) }
  scope :dated,   ->(date) { where(date: date) }

  # TODO: might have to fix with changes to `created_at`
  def self.counted(range = nil)
    query = where(counted: true)
    query = query.where(created_at: range) if range.present?
    query
  end

  def self.countable(*range)
    query = where(counted: true)

    query = query.where(:created_at.gte => range[0], :created_at.lte => range[1]) if range.present?

    query
  end

  def notify_bugsnag(error)
    Bugsnag.notify(error) do |report|
      report.severity = 'error'
      report.add_tab(:watch_time, attributes.merge(errors: errors.messages))
      report.add_tab(:view_tracking, view_tracking.bugsnag_attributes)
    end
  end

  private

  # TODO: move functions shared with view to concern
  def correct_event_timestamps
    start_event = view_tracking.event_timestamps.reverse_each.detect { |e| e.values.first == started_at }
    end_event   = view_tracking.event_timestamps.reverse_each.detect { |e| e.values.first == ended_at }
    errors.add(:started_at, "invalid start time: #{started_at}") if start_event.nil?
    errors.add(:ended_at,   "invalid end time: #{ended_at}")     if end_event.nil?
  end

  def initialize_from_view_tracking # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    return if view_tracking.blank?

    self.post       ||= view_tracking.post
    self.user       ||= post.user
    self.watched_by ||= view_tracking.user
    self.total      ||= view_tracking.progress

    # store event timestamps
    self.started_at ||= view_tracking.start_time
    self.ended_at   ||= view_tracking.end_time

    # log constants at the time of creation
    self.minimum_view ||= ViewTracking::MINIMUM_VIEW
  end

  def set_date
    self.date = started_at.to_date
  end

  def watch_time_eligible
    return if user && user != watched_by

    errors.add(:user, "can't earn watch time on own contents")
  end
end
