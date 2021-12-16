# frozen_string_literal: true

module Paypal
  class SendRequestService
    def initialize(path:, method:, body: nil)
      @path = path
      @method = method
      @body = body
    end

    def call
      send_request
    end

    private

    attr_reader :path, :method, :body

    def send_request
      url = URI("#{ENV['PAYPAL_URL']}#{path}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP.const_get(method.capitalize).new(url)
      request['authorization'] = "Bearer #{Paypal::GetAccessTokenService.new.call}"
      request['content-type'] = 'application/json'
      request.body = body.to_json if body.present?

      http.request(request)
    end
  end
end
