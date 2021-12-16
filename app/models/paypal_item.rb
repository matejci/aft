# frozen_string_literal: true

class PaypalItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :paypal_batch
  belongs_to :paypal_account

  field :payout_ids, type: Array
  field :amount_in_cents, type: Integer
  field :adjusted_amount_in_cents, type: Integer
  field :fee_in_cents, type: Integer
  field :paypal_email, type: String
  field :paypal_country, type: String
  field :transaction_id, type: String
  field :transaction_status, type: String
  field :paypal_detail, type: Hash

  # NOTE: transaction statuses https://developer.paypal.com/docs/api/payments.payouts-batch/v1/#definition-transaction_status
  #
  # SUCCESS. Funds have been credited to the recipient’s account.
  # FAILED. This payout request has failed, so funds were not deducted from the sender’s account.
  # PENDING. Your payout request was received and will be processed.
  # UNCLAIMED. The recipient for this payout does not have a PayPal account.
  #   A link to sign up for a PayPal account was sent to the recipient.
  #   However, if the recipient does not claim this payout within 30 days, the funds are returned to your account.
  # RETURNED. The recipient has not claimed this payout, so the funds have been returned to your account.
  # ONHOLD. This payout request is being reviewed and is on hold.
  # BLOCKED. This payout request has been blocked.
  # REFUNDED. This payout request was refunded.
  # REVERSED. This payout request was reversed.

  validates :amount_in_cents, :paypal_email, :payout_ids, presence: true
end
