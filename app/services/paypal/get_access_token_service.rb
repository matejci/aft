# frozen_string_literal: true

module Paypal
  class GetAccessTokenService
    def call
      generate_access_token
    end

    private

    def generate_access_token
      Rails.cache.read('paypal_access_token') || begin
        url = URI("#{ENV['PAYPAL_URL']}/v1/oauth2/token")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(url)
        request['content-type'] = 'application/x-www-form-urlencoded'
        request.basic_auth(ENV['PAYPAL_CLIENT_ID'], ENV['PAYPAL_SECRET'])
        request.body = 'grant_type=client_credentials'

        response = http.request(request)
        result = JSON.parse(response.body)

        Rails.cache.write('paypal_access_token', result['access_token'], expires_in: result['expires_in'])
        result['access_token']
      end
    end
  end
end
