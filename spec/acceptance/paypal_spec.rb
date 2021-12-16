# frozen_string_literal: true

require 'acceptance_helper'

resource 'Paypal' do
  route '/paypal/webhook', 'webhook' do
    header 'USER-AGENT', 'PayPal'
    parameter :paypal, 'paypal params'

    let(:paypal) do
      JSON.parse(File.read('spec/fixtures/paypal_webhook/item.json'))
    end

    before do
      ActiveJob::Base.queue_adapter = :test
      allow(Paypal::VerifyWebhookService).to receive_message_chain('new.call').and_return(true)
    end

    post 'paypal webhook' do
      example_request '204' do
        expect(PaypalEventHandlerJob).to have_been_enqueued.with(event: paypal)
        expect(status).to eq 204
      end
    end
  end
end
