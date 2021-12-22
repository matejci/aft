# frozen_string_literal: true

require 'acceptance_helper'

resource 'API::V1::Banners' do
  include_context 'authenticated request'
  header 'X-API-VERSION', 'api.appforteachers.v1'

  before { create_list(:banner, 5, order: rand(10)) }

  route '/banners.json', 'Banners' do
    get 'banners' do
      example '200' do
        do_request

        expect(status).to eq 200
        expect(parsed_response).to include('total_pages' => 1)
        expect(parsed_response['data']).to be_an_instance_of(Array)
        expect(parsed_response['data'].size).to eq(5)
        orders = parsed_response['data'].map { |banner| banner['order'] }
        expect(orders).to eq(orders.sort)
      end
    end
  end
end
