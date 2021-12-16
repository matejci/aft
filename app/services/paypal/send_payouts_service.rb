# frozen_string_literal: true

module Paypal
  class SendPayoutsService
    def initialize(batch:)
      @batch = batch
    end

    def call
      send_payouts
    end

    private

    attr_reader :batch

    def send_payouts
      paypal_items = batch.paypal_items
      payout_items = generate_payout_items(paypal_items)

      response = Paypal::SendRequestService.new(
        path: '/v1/payments/payouts',
        method: 'post',
        body: {
          sender_batch_header: {
            sender_batch_id: batch.id.to_s,
            recipient_type: 'EMAIL',
            email_subject: 'You just got paid! 💰',
            email_message: 'Congrats! Your payout earnings are on the way to your paypal account!'
          },
          items: payout_items
        }
      ).call

      parsed_body = JSON.parse(response.body)

      if response.is_a? Net::HTTPSuccess
        batch.update!(
          payout_batch_id: parsed_body['batch_header']['payout_batch_id'],
          batch_status: parsed_body['batch_header']['batch_status']
        )

        paypal_items.each do |item|
          Payout.in(id: item.payout_ids).update_all(status: :in_delivery, paypal_item_id: item.id)
        end
      else
        batch.update!(paypal_error: parsed_body)

        ReportErrorService.new(
          name: 'Paypal::SendPayoutsServiceError',
          data: {
            response: response,
            paypal_batch_id: batch.id,
            payout_items: payout_items,
            paypal_error: parsed_body
          }
        ).call
      end
    end

    def generate_payout_items(paypal_items)
      paypal_items.map do |item|
        {
          amount: { currency: 'USD', value: (item.adjusted_amount_in_cents / 100.0) },
          receiver: item.paypal_email,
          note: "PAYOUTS (#{batch.date.strftime('%m/%d/%Y')})",
          sender_item_id: "#{batch.id}_#{item.id}"
        }
      end
    end
  end
end
