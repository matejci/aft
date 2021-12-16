# frozen_string_literal: true

FactoryBot.define do
  factory :paypal_item do
    paypal_account
    paypal_batch

    amount_in_cents { rand(1..50_000) }
    paypal_email { paypal_account.email }
    payout_ids { [1, 2] }

    before(:create) do |item|
      item.fee_in_cents = item.amount_in_cents * 0.02 <= 25 ? 25 : (item.amount_in_cents / 102.0 * 2).round
      item.adjusted_amount_in_cents = item.amount_in_cents - item.fee_in_cents
    end

    trait :personal do
      paypal_email { 'personal@us.example.com' }
    end

    trait :business do
      paypal_email { 'business@us.example.com' }
    end

    trait :ca do
      paypal_email { 'personal@ca.example.com' }
    end
  end
end
