# frozen_string_literal: true

class Pool
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include Mongoid::History::Trackable

  # e.g. US(parent)/US Beauty(child)
  belongs_to :parent,   class_name: 'Pool', counter_cache: true, optional: true, touch: true
  has_many   :subpools, class_name: 'Pool', inverse_of: :parent, dependent: :nullify

  has_many :intervals, class_name: 'PoolInterval', dependent: :destroy
  accepts_nested_attributes_for :intervals, allow_destroy: true

  delegate :eligible_creators_count, to: :class

  field :name,               type: String
  field :description,        type: String
  field :status,             type: Boolean, default: false
  field :amount,             type: Float
  field :estimated_amount,   type: Float,   default: 0
  field :daily_amount,       type: Float,   default: 0
  field :fixed_amount,       type: Float,   default: 0
  field :transferred_amount, type: Float,   default: 0
  field :processed_amount,   type: Float,   default: 0
  field :paid_amount,        type: Float,   default: 0
  field :remaining_amount,   type: Float,   default: 0
  field :start_date,         type: Date     # can start on any day of the month
  field :end_date,           type: Date     # always the last day of the month for now
  field :subpools_count,     type: Integer, default: 0
  # field :target_watch_time_rate, type: Float

  attr_accessor :modified_by

  track_history modifier_field_optional: true

  before_validation :set_estimated_amount, on: :create
  before_validation :set_modifier

  validates :amount, :name, :start_date, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, if: :amount
  validates :daily_amount, presence: true, if: -> { estimated_amount.positive? }
  validates :daily_amount, numericality: { greater_than_or_equal_to: 0 }, if: :daily_amount
  validate  :check_available_amount, if: :amount_changed?

  before_save :redistribute_amount, if: :redistribute_needed?

  before_destroy :check_if_processed

  with_options if: :start_date_changed? do
    validate :already_processed, on: :update

    before_save :set_end_date, :set_amounts
    before_save :generate_intervals
  end

  def self.eligible_creators_count(refresh: false)
    Rails.cache.fetch('eligible_creators_count', force: refresh) do
      User.can_monetize.count
    end
  end

  def redistribute_needed?
    # NOTE: false if already generated intervals or has intervals attributes
    amount_changed? && !(start_date_changed? || intervals.any? { |i| i.changes.any? })
  end

  def amount_change=(change)
    self.amount += change
  end

  def estimated_amount_change=(change)
    self.estimated_amount += change
  end

  def fixed_amount_change=(change)
    self.fixed_amount += change
  end

  def process!(amount:, fixed:, modifier:)
    if fixed
      self.fixed_amount -= amount
    else
      self.estimated_amount -= amount
    end

    self.processed_amount += amount
    self.modified_by = modifier

    save!
  end

  def subpool?
    parent.present?
  end

  def type
    subpool? ? 'pool' : 'subpool'
  end

  private

  def dates
    start_date..end_date
  end

  def already_processed
    return unless intervals.processed.any?

    errors.add(:start_date, "can't modify start date on pool that has processed intervals")
  end

  def allocated_amount
    fixed_amount + processed_amount + paid_amount
  end

  def check_available_amount
    return unless !errors.key?('amount') && (amount - allocated_amount).negative?

    errors.add(:amount, 'insufficient funds to cover fixed, processed, and paid amount')
  end

  def check_if_processed
    return unless intervals.processed.any?

    errors.add(:base, 'pool already started processing')
    throw(:abort)
  end

  def set_estimated_amount
    return if amount.blank?

    self.estimated_amount = amount - allocated_amount
  end

  def set_end_date
    return if start_date.blank?

    self.end_date = start_date.end_of_month
  end

  def set_amounts
    self.estimated_amount = amount
    self.daily_amount = estimated_amount / dates.count
    self.fixed_amount = 0
  end

  def set_modifier
    self.modifier = modified_by
  end

  # intervals

  def generate_intervals
    # remove intervals if any exists
    intervals_attrs = intervals.map { |i| { id: i.id, _destroy: true } }
    intervals_attrs += dates.map { |d| { amount: daily_amount, date: d } }

    self.intervals_attributes = intervals_attrs
  end

  def redistribute_amount
    set_estimated_amount
    return unless intervals.estimated.any?

    estimated_intervals = intervals.estimated
    self.daily_amount = estimated_amount / estimated_intervals.length
    self.intervals_attributes = estimated_intervals.map { |i| { id: i.id, amount: daily_amount } }
  end
end
