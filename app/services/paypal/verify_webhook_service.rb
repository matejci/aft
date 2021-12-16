# frozen_string_literal: true

module Paypal
  class VerifyWebhookService
    def initialize(request:)
      @request = request
    end

    def call
      verify_webhook
    end

    private

    attr_reader :request

    def verify_webhook
      response = Paypal::SendRequestService.new(
        path: '/v1/notifications/verify-webhook-signature',
        method: 'post',
        body: body
      ).call

      if response.is_a?(Net::HTTPSuccess) && JSON.parse(response.body)['verification_status'] == 'SUCCESS'
        true
      else
        ReportErrorService.new(name: 'Paypal::VerifyWebhookServiceError', data: { response: response, body: body }).call
      end
    end

    def body
      @body ||= {
        transmission_id: request.headers['PAYPAL-TRANSMISSION-ID'],
        transmission_time: request.headers['PAYPAL-TRANSMISSION-TIME'],
        cert_url: request.headers['PAYPAL-CERT-URL'],
        auth_algo: request.headers['PAYPAL-AUTH-ALGO'],
        transmission_sig: request.headers['PAYPAL-TRANSMISSION-SIG'],
        webhook_id: ENV['PAYPAL_WEBHOOK_ID'],
        webhook_event: request.params['paypal']
      }
    end
  end
end
