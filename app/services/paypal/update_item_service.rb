# frozen_string_literal: true

# NOTE: transaction statuses
# success pending unclaimed onhold
# failed returned => unpaid
# blocked refunded reversed => raise error

module Paypal
  class UpdateItemService
    def initialize(resource:)
      @resource = resource
    end

    def call
      update_item
    end

    private

    attr_reader :resource

    def update_item
      item = PaypalItem.find(resource['payout_item']['sender_item_id'].split('_').last)
      status = resource['transaction_status']

      PaypalItem.with_session do |session|
        session.start_transaction

        item.transaction_id = resource['transaction_id']
        item.transaction_status = status
        item.paypal_detail = resource.slice('payout_item_id', 'payout_batch_id', 'errors')
        item.save!

        update_payouts(item.payout_ids, status)

        session.commit_transaction
      end

      return unless status.match?(/FAILED|RETURNED|BLOCKED|REFUNDED|REVERSED/)

      # NOTE: BLOCKED|REFUNDED|REVERSED need to be reviewed further

      ReportErrorService.new(
        name: 'Paypal::UpdateItemServiceError',
        data: { paypal_item_id: item.id, resource: resource }
      ).call
    end

    def update_payouts(payout_ids, status)
      payouts = Payout.in(id: payout_ids)
      updates = { paypal_status: status }

      case status
      when 'SUCCESS'
        updates[:status] = :paid
      when /FAILED|RETURNED/
        updates[:status] = :unpaid
      end

      payouts.update_all(updates)
    end
  end
end
