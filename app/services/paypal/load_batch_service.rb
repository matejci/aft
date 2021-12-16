# frozen_string_literal: true

module Paypal
  class LoadBatchService
    def initialize(id:)
      @id = id
    end

    def call
      load_batch
    end

    private

    attr_reader :id

    def load_batch
      response = Paypal::SendRequestService.new(
        path: "/v1/payments/payouts/#{id}",
        method: 'get'
      ).call

      JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)
    end
  end
end
