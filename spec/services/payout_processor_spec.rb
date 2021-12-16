# frozen_string_literal: true

require 'rails_helper'

describe PayoutProcessor, type: :model do
  let(:date) { '2021-03-10'.to_date }
  let(:user) { create(:user, monetization_status: true) }
  let(:non_monetizing_user) { create(:user, monetization_status: false) }
  let(:canadian_user) { create(:user, monetization_status: true) }
  let(:pending_balance_user) { create(:user, monetization_status: true) }
  let(:no_paypal_user) { create(:user, monetization_status: true) }
  let(:pool) { create(:pool, amount: 1000, processed_amount: 1000) }
  let(:pool_interval) { create(:pool_interval, pool: pool, date: date) }

  before do
    3.times do
      payout = create(:payout, user: user, pool_interval: pool_interval, status: :unpaid)
      payout.set(paying_amount_in_cents: 2500)
    end
    2.times { create(:payout, user: non_monetizing_user, pool_interval: pool_interval, status: :unpaid) }
    payout = create(:payout, user: canadian_user, pool_interval: pool_interval, status: :unpaid)
    payout.set(paying_amount_in_cents: 300)
    payout = create(:payout, user: pending_balance_user, pool_interval: pool_interval, status: :unpaid)
    payout.set(paying_amount_in_cents: 3)
    payout = create(:payout, user: no_paypal_user, pool_interval: pool_interval, status: :unpaid)
    payout.set(paying_amount_in_cents: 500)

    user.paypal_account.update(email: 'personal@us.example.com')
    canadian_user.paypal_account.update(email: 'personal@ca.example.com')
    pending_balance_user.paypal_account.update(email: pending_balance_user.email)
  end

  describe '#call' do
    subject(:payout_processor) { PayoutProcessor.new(date: date).call }

    context 'valid date' do
      it 'processes payouts' do
        is_expected.not_to be_nil
        expect(payout_processor[:success]).to eq true
        expect(payout_processor[:batch_items_count]).to eq 2 # user, canadian_user
        expect(payout_processor[:pending_items_count]).to eq 2 # pending_balance_user, no_paypal_user
        expect(PaypalBatch.count).to eq 1
        expect(PaypalItem.all.pluck(:paypal_account_id)).to include user.paypal_account.id, canadian_user.paypal_account.id
        expect(Payout.paid.pluck(:id)).to contain_exactly(*user.payouts.pluck(:id), *canadian_user.payouts.pluck(:id))
      end
    end

    context 'non payout date' do
      let(:date) { '2021-03-01'.to_date }

      it 'does not process payouts' do
        is_expected.to be_nil
      end
    end
  end
end
