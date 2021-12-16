# frozen_string_literal: true

class View
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :post
  belongs_to :user, index: true
  belongs_to :view_tracking
  belongs_to :viewed_by, class_name: 'User', optional: true

  # view tracking constants
  field :minimum_view, type: Integer

  field :started_at, type: DateTime
  field :ended_at,   type: DateTime
  field :date,       type: Date

  field :counted,   type: Boolean
  field :retention, type: Float

  scope :counted, -> { where(counted: true) }
  scope :dated,   ->(date) { where(date: date) }

  before_validation :initialize_from_view_tracking, if: :new_record?

  before_create :set_date

  validates :started_at, :ended_at, presence: true
  validates :started_at, uniqueness: { scope: :view_tracking_id }
  validates :retention, inclusion: 0..1, allow_nil: true
  validate  :correct_event_timestamps

  after_destroy { |v| v.update_total_views(-1) if v.counted? }

  # TODO: might have to fix with changes to `created_at`
  def self.countable(*range)
    query = where(counted: true)

    query = query.where(:created_at.gte => range[0], :created_at.lte => range[1]) if range.present?

    query
  end

  def notify_bugsnag(error)
    Bugsnag.notify(error) do |report|
      report.severity = 'error'
      report.add_tab(:view, attributes.merge(errors: errors.messages))
      report.add_tab(:view_tracking, view_tracking.bugsnag_attributes)
    end
  end

  def update_total_views(count = 1)
    return if post.blank?

    post.atomically do
      post.inc(total_views: count)
      post.set(counts_updated_at: Time.current)
    end
  end

  private

  def correct_event_timestamps
    start_event = view_tracking.event_timestamps.reverse_each.detect { |e| e.values.first == started_at }
    end_event   = view_tracking.event_timestamps.reverse_each.detect { |e| e.values.first == ended_at }
    errors.add(:started_at, "invalid start time: #{started_at}") if start_event.nil?
    errors.add(:ended_at,   "invalid end time: #{ended_at}")     if end_event.nil?
  end

  def initialize_from_view_tracking # rubocop: disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return if view_tracking.blank?

    self.post      ||= view_tracking.post
    self.user      ||= post.user
    self.viewed_by ||= view_tracking.user
    self.retention ||= view_tracking.retention

    # store event timestamps
    self.started_at ||= view_tracking.start_time
    self.ended_at   ||= view_tracking.end_time

    # log constants at the time of creation
    self.minimum_view ||= ViewTracking::MINIMUM_VIEW
  end

  def set_date
    self.date = started_at.to_date
  end
end
