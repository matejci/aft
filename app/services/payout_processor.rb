# frozen_string_literal: true

class PayoutProcessor
  def initialize(date: Date.current)
    @date = date
  end

  def call
    process_payouts
  end

  private

  attr_reader :date

  def process_payouts
    return unless date.wednesday? # process eligible creator payouts weekly on Wednesdays

    payouts = eligible_payouts
    return if payouts.none?

    batch_items = []
    pending_items = []

    payout_items(payouts).each do |item|
      if item['paypal_email'].present? && item['amount_in_cents'] > PaypalBatch::MINIMUM_THRESHOLD
        batch_items << item.except('user_id')
      else
        pending_items << item.slice('user_id', 'amount_in_cents')
      end
    end

    Paypal::CreateBatchService.new(date: date, items: batch_items).call

    # NOTE: currently disabling sending of `payout` notifications
    # send_pending_notifications(pending_items)

    { success: true, batch_items_count: batch_items.length, pending_items_count: pending_items.length }
  end

  def eligible_payouts
    Payout.unpaid.in(
      user_id: User.where(monetization_status: true).pluck(:id)
    ).where(
      :date.lte => date, :paying_amount_in_cents.gt => 0
    )
  end

  def payout_items(payouts)
    payouts.group(
      _id: '$user_id',
      :payout_ids.push => '$_id',
      amount_in_cents: { '$sum': '$paying_amount_in_cents' }
    ).lookup(
      from: 'paypal_accounts', localField: '_id', foreignField: 'user_id', as: 'pa'
    ).unwind(
      { path: '$pa', preserveNullAndEmptyArrays: true }
    ).project(
      _id: 0,
      user_id: '$_id',
      payout_ids: 1,
      amount_in_cents: 1,
      paypal_account_id: '$pa._id',
      paypal_email: '$pa.email'
    ).aggregate
  end

  def send_pending_notifications(items)
    items.each do |item|
      next unless (user = User.find(item['user_id']))

      PushNotifications::ProcessorService.new(
        action: :payout, notifiable: user, actor: User.aft_user, recipient: user, body: item['amount_in_cents'] / 100.0
      ).call
    end
  end
end
