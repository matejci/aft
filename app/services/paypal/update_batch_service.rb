# frozen_string_literal: true

# NOTE: batch statuses
# pending processing success
# denied canceled => raise error

module Paypal
  class UpdateBatchService
    def initialize(resource:)
      @resource = resource
    end

    def call
      update_batch
    end

    private

    attr_reader :resource

    def update_batch
      batch_header = resource['batch_header']
      batch = PaypalBatch.find(batch_header['sender_batch_header']['sender_batch_id'])

      status = batch_header['batch_status']
      batch.batch_status = status
      batch.payout_batch_id = batch_header['payout_batch_id']
      batch.paypal_detail = batch_header.slice('time_created', 'time_completed', 'amount', 'fees', 'payments')
      batch.save!

      return unless status.match?(/DENIED|CANCELED/)

      ReportErrorService.new(
        name: 'Paypal::UpdateBatchServiceError',
        data: { paypal_batch_id: batch.id, resource: resource }
      ).call
    end
  end
end
