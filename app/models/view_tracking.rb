# frozen_string_literal: true

class ViewTracking
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  ACTION_STATUS = {
    'start' => :started,
    'pause' => :paused,
    'resume' => :resumed,
    'end' => :ended,
    'buffering_start' => :buffering_started,
    'buffering_end' => :buffering_ended
  }.freeze

  # 1+ seconds count as view
  MINIMUM_VIEW = 1

  belongs_to :post
  belongs_to :session
  belongs_to :user,        optional: true # NOTE: user is viewer
  has_many   :views,       dependent: :destroy
  has_many   :watch_times, dependent: :destroy

  field :current_counts, type: Array, default: []
  field :event_timestamps, type: Array, default: []

  field :last_activity,       type: DateTime
  field :last_logged_index,   type: Integer, default: -1
  field :video_length,        type: Float
  field :watch_time_eligible, type: Boolean
  field :source, type: String
  field :flagged, type: String, default: nil

  enum :status, ACTION_STATUS.values

  attr_accessor :current_time, :end_time, :previous, :progress, :start_time, :looping

  validates :session, uniqueness: { scope: :post }

  # NOTE: ORDER matters !! need info from post & session before setting eligiblity
  before_create :initialize_from_post, :initialize_from_session, :set_watch_time_eligible

  with_options if: :status_changed? do
    before_save :timestamp_status
    after_save  :log_views, if: :ended?
  end

  def self.init_with(session, post)
    find_or_create_by!(post: post, session: session)
  rescue StandardError => e
    meta_data = { post_id: post.id, session_id: session.id, retried: @retried }
    Bugsnag.leave_breadcrumb('retrying ViewTracking.init_with', meta_data)
    if @retried.nil?
      @retried = true
      retry
    else
      Bugsnag.notify(e) do |report|
        report.severity = 'error'
        report.add_tab(:view_tracking, { post_id: post.id, session_id: id })
      end
    end
  end

  def currently_being_viewed?
    @currently_being_viewed ||= (session.currently_viewing_id == id)
  end

  def bugsnag_attributes
    attributes.merge({
                       current_time: current_time,
                       progress: progress,
                       start_time: start_time,
                       end_time: end_time,
                       event: event,
                       view_ids: view_ids,
                       watch_time_ids: watch_time_ids,
                       errors: errors.messages
                     })
  end

  def event=(event)
    if event == 'start' && %i[started resumed buffering_ended].include?(status)
      self.looping = true
    else
      self.looping = false
      self.status  = ACTION_STATUS[event]
    end
  end

  def ended_at(time)
    return if ended? # ignore if already ended

    self.status = :ended
    self.current_time = time
    save
  end

  def notify_bugsnag(error)
    Bugsnag.notify(error) do |report|
      report.severity = 'error'
      report.add_tab(:view_tracking, bugsnag_attributes)
    end
  end

  def record
    if looping && currently_being_viewed?
      self.status = :ended
      save
      self.status = :started
    end

    self.last_activity = current_time
    save

    return if currently_being_viewed?

    session.currently_viewing&.ended_at(current_time)
    session.set(currently_viewing_id: id)
  end

  def retention
    return unless progress.present? && video_length.present?

    progress / video_length
  end

  def valid_progress?
    # greater than minimum and within acceptable range (2.0 to account for request delays)
    # NOTE: unique & minimum variables might get different for view and watch time later
    if (MINIMUM_VIEW <= progress) && (progress < (video_length + 2.0))
      self.progress = video_length if progress > video_length # cap progress to video length
      true
    else
      false
    end
  end

  private

  def log_views
    current_index = event_timestamps.size - 1
    ViewLoggerJob.perform_later(id.to_s, last_logged_index, current_index)
    set(last_logged_index: current_index)
  end

  def initialize_from_post
    self.video_length = post.video_length
  end

  def initialize_from_session
    self.user_id = session.user_id
    self.flagged = 'sogou_explorer' if session.device_client_name&.match?(/sogou/i)
  end

  def set_watch_time_eligible
    # can't earn watch time on own contents
    self.watch_time_eligible = (post.user_id != user_id)
  end

  def timestamp_status
    event_timestamps << { "#{status}": current_time }
  end
end
