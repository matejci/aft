# frozen_string_literal: true

module Paypal
  class CreateBatchService
    def initialize(date:, items:)
      @date = date
      @items = items
    end

    def call
      create_batch
    end

    private

    attr_reader :date, :items

    def create_batch
      return if items.none?

      batch = PaypalBatch.new(date: date)
      items.each { |item| batch.paypal_items.new(item.merge(amount_and_fee(item['amount_in_cents']))) }
      batch.save!

      Paypal::SendPayoutsService.new(batch: batch).call
    end

    def amount_and_fee(amount_in_cents)
      fee = amount_in_cents * 0.02 <= 25 ? 25 : (amount_in_cents / 102.0 * 2).round

      { adjusted_amount_in_cents: amount_in_cents - fee, fee_in_cents: fee }
    end
  end
end
