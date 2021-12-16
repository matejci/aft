# frozen_string_literal: true

class PaypalController < ApplicationController
  before_action :verify_webhook

  def webhook
    params.permit!
    PaypalEventHandlerJob.perform_later(event: params['paypal'])
  end

  private

  def verify_webhook
    return if Paypal::VerifyWebhookService.new(request: request).call

    head :unauthorized
  end
end
