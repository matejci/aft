# frozen_string_literal: true

class PoolInterval
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include Mongoid::History::Trackable

  VALIDATION_PERIOD = 3.days.freeze

  belongs_to :pool
  has_many :payouts, dependent: :destroy

  has_and_belongs_to_many :users, index: true
  has_and_belongs_to_many :watch_times, index: true

  accepts_nested_attributes_for :payouts

  field :amount,            type: Float,   default: 0
  field :fixed,             type: Boolean, default: false
  field :date,              type: Date
  field :payouts_count,     type: Integer, default: 0
  field :processing_date,   type: Date
  field :total_watch_time,  type: Float
  field :watch_time_rate,   type: Float
  field :watch_time_loaded, type: Boolean, default: false

  enum :status, %i[forecasted processed], default: :forecasted

  attr_accessor :modified_by, :processing, :skip_watch_time_calc

  track_history scope: :pool, modifier_field_optional: true

  scope :dated,     ->(date) { where(date: date) }
  scope :estimated, -> { forecasted.where(fixed: false) }

  validates :amount, :date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :amount

  before_validation :set_modifier
  before_validation :set_processing
  before_validation :set_processing_date, if: :date_changed?

  after_save :delay_load_watch_times, if: :load_eligible?

  with_options if: :amount_changed? do
    validate :fixed_amount, on: :update
    after_update :update_pool_amount
  end

  with_options if: :watch_time_ids_changed? do
    validate    :not_yet_processed
    before_save :calc_watch_time, unless: :skip_watch_time_calc
    before_save :generate_payouts
  end

  with_options if: :processing do
    validate    :can_process?
    # NOTE: will be processing payouts on processing date
    # before_save :process_payouts
    after_save  :process_pool
  end

  def self.process_payouts!(date)
    PoolInterval.processed.where(processing_date: date).each do |interval|
      interval.process_payouts
      interval.save
    end
  end

  def load_eligible?
    # TODO: date < Date.today
    forecasted? && !watch_time_loaded && (date <= Time.zone.today)
  end

  def load_watch_times
    # TODO: put it in job?
    return if watch_time_loaded

    result = MonetizableWatchTimeQuery.for(date)
    return if result.nil?

    self.user_ids = result['user_ids']
    self.watch_time_ids = result['watch_time_ids']
    self.total_watch_time = result['total']

    self.watch_time_rate = amount / total_watch_time
    self.skip_watch_time_calc = true
    self.watch_time_loaded = true
    save!
  end

  def process_payouts
    self.payouts_attributes = payouts.map { |po| { id: po.id, status: :unpaid } }
  end

  def validate_by
    processing_date - 1
  end

  private

  def calc_watch_time
    self.total_watch_time = watch_times.sum(:total)
    self.watch_time_rate = amount / total_watch_time
  end

  def can_process?
    return if (date < Time.zone.today) && watch_time_loaded

    errors.add(:date, 'watchtimes are still being counted')
  end

  def delay_load_watch_times
    PoolIntervalLoadWatchtimesJob.perform_later(pool_interval_id: id.to_s)
  end

  def fixed_amount
    return if fixed || pool.changed?

    errors.add(:amount, "can't change estimated amount")
  end

  def generate_payouts
    payouts.destroy_all
    self.payouts_attributes = MonetizableWatchTimeQuery.users(watch_times).map do |u|
      { user_id: u['_id'], watch_time: u['total_watch_time'], status: :pending }
    end
  end

  def not_yet_processed
    return if forecasted?

    errors.add(:status, "can't modify watch times on already processed interval")
  end

  def process_pool
    pool.process!(amount: amount, fixed: fixed, modifier: modified_by)
  end

  def set_modifier
    self.modified_by ||= pool&.modified_by
    self.modifier = modified_by if modified_by
  end

  def set_processing
    return unless status_changed? && processed?

    # NOTE: to prevent 2nd set of callbacks caused by autosave
    self.processing = processing.nil?
  end

  def set_processing_date
    # interval will be processed on the day following the validation period
    self.processing_date = [Time.zone.today, date].max + VALIDATION_PERIOD + 1
  end

  def update_pool_amount
    # NOTE: return if pool already has changes
    return if pool.changed? # Mongoid::Threaded.autosaved? pool

    amount_change = amount - amount_was
    pool.amount_change = amount_change
    pool.modified_by = modified_by

    if fixed_was # previously fixed
      pool.fixed_amount_change = amount_change
    else
      pool.estimated_amount_change = -amount_was
      pool.fixed_amount_change = amount
    end

    pool.save!
  end
end
