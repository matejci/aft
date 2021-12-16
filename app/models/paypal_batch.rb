# frozen_string_literal: true

class PaypalBatch
  MINIMUM_THRESHOLD = 200

  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :paypal_items, dependent: :destroy, autosave: true

  field :date, type: Date
  field :paypal_error, type: Hash

  # paypal fields

  field :payout_batch_id, type: String
  field :batch_status, type: String
  field :paypal_detail, type: Hash

  # NOTE: batch statuses https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#definition-payout_batch_items
  #
  # DENIED. Your payout requests were denied, so they were not processed. Check the error messages to see any steps necessary to fix these issues.
  # PENDING. Your payout requests were received and will be processed soon.
  # PROCESSING. Your payout requests were received and are now being processed.
  # SUCCESS. Your payout batch was processed and completed. Check the status of each item for any holds or unclaimed transactions.
  # CANCELED. The payouts file that was uploaded through the PayPal portal was cancelled by the sender.

  validates :date, presence: true
end
