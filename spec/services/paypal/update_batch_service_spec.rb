# frozen_string_literal: true

require 'rails_helper'

describe Paypal::UpdateBatchService, type: :model do
  let(:paypal_params) do
    ActiveSupport::HashWithIndifferentAccess.new(
      JSON.parse(File.read('spec/fixtures/paypal_webhook/batch.json'))
    )
  end

  let(:batch) { create(:paypal_batch) }

  before do
    allow(PaypalBatch).to receive(:find).with('619ee6cd5adab639ef88bfc4').and_return(batch)
  end

  describe '#call' do
    subject(:update_batch) { Paypal::UpdateBatchService.new(resource: paypal_params[:resource]).call }

    it 'returns errors' do
      expect(batch.batch_status).to eq nil

      update_batch

      expect(batch.reload.batch_status).to eq 'PROCESSING'
    end
  end
end
