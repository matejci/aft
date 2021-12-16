# frozen_string_literal: true

require 'rails_helper'

describe Paypal::UpdateItemService, type: :model do
  let(:paypal_params) do
    ActiveSupport::HashWithIndifferentAccess.new(
      JSON.parse(File.read('spec/fixtures/paypal_webhook/item.json'))
    )
  end

  let(:payout) { create(:payout) }
  let(:item) { create(:paypal_item, payout_ids: [payout.id]) }

  before do
    allow(PaypalItem).to receive(:find).with('619ee6df5adab63a13f4c597').and_return(item)
  end

  describe '#call' do
    subject(:update_item) { Paypal::UpdateItemService.new(resource: paypal_params[:resource]).call }

    it 'returns errors' do
      expect(item.transaction_status).to eq nil
      expect(payout.paypal_status).to eq nil

      update_item

      item.reload
      payout.reload
      expect(item.transaction_status).to eq 'UNCLAIMED'
      expect(payout.paypal_status).to eq item.transaction_status
    end
  end
end
