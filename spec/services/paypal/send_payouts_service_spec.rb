# frozen_string_literal: true

require 'rails_helper'

describe Paypal::SendPayoutsService, type: :model do
  let(:batch) { create(:paypal_batch) }

  describe '#call' do
    subject(:send_payouts) { Paypal::SendPayoutsService.new(batch: batch).call }

    context 'no payout items' do
      it 'returns errors' do
        send_payouts
        expect(batch.reload.paypal_error).to be_present
      end
    end

    context 'payout items' do
      before do
        2.times { create(:paypal_item, paypal_batch: batch) }
        create(:paypal_item, :personal, paypal_batch: batch)
        create(:paypal_item, :business, paypal_batch: batch)
        create(:paypal_item, :ca, paypal_batch: batch)
      end

      it 'processes payouts' do
        send_payouts
        batch_detail = Paypal::LoadBatchService.new(id: batch.reload.payout_batch_id).call
        batch_amounts = batch_detail['items'].map { |item| item.dig('payout_item', 'amount', 'value').to_f }

        expect(batch_amounts).to contain_exactly(*PaypalItem.all.pluck(:adjusted_amount_in_cents).map { |amount| amount / 100.0 })
      end
    end
  end
end
