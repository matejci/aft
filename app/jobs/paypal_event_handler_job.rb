# frozen_string_literal: true

class PaypalEventHandlerJob < ApplicationJob
  queue_as :paypal_events
  sidekiq_options retry: 2

  def perform(event:)
    case event['event_type']
    when /PAYOUTSBATCH/
      Paypal::UpdateBatchService.new(resource: event['resource']).call
    when /PAYOUTS-ITEM/
      Paypal::UpdateItemService.new(resource: event['resource']).call
    end
  end
end
