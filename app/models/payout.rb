# frozen_string_literal: true

class Payout
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  belongs_to :pool
  belongs_to :pool_interval, counter_cache: :payouts_count
  belongs_to :user

  delegate :username, :full_name, to: :user, prefix: :user
  # pool interval fields
  field :date, type: Date
  field :watch_time_rate, type: Float

  field :currency, type: String, default: 'usd'
  field :amount, type: Float
  field :paying_amount_in_cents, type: Integer
  field :remaining_amount, type: Float
  field :ratio, type: Float # ratio of wt to total_wt on pool interval
  field :watch_time, type: Float
  field :counted_views, type: Float
  field :total_views, type: Float

  # paypal related fields when payout to paypal is initiated
  field :paypal_item_id, type: String
  field :paypal_status, type: String

  # archived stripe data
  field :stripe_payout_id,   type: String
  field :stripe_transfer_id, type: String

  # NOTE: default will be `pending` for existing watch time
  # `estimate` for forecatsted watch time (future feature)
  enum :status, %i[estimate pending unpaid in_delivery paid denied]

  scope :dated,     ->(date) { where(date: date) }
  scope :finalized, -> { where.in(status: %i[unpaid in_delivery paid]) }

  validates :amount, presence: { message: 'Payout amount required' }

  before_validation :initialize_from_interval, :set_views, on: :create
  before_save :set_paying_amount, if: :amount_changed?

  def paying_amount
    paying_amount_in_cents / 100.0
  end

  def percent
    ratio * 100
  end

  private

  def initialize_from_interval
    self.amount  = pool_interval.watch_time_rate * watch_time
    self.date    = pool_interval.date
    self.ratio   = watch_time / pool_interval.total_watch_time
    self.pool_id = pool_interval.pool_id
  end

  def set_paying_amount
    self.paying_amount_in_cents = (amount * 100).to_i
    self.remaining_amount = BigDecimal(amount.to_s) - BigDecimal(paying_amount.to_s)
  end

  def set_views
    views = user.views.dated(date)
    self.counted_views = views.counted.count
    self.total_views   = views.count
  end
end
