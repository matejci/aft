# frozen_string_literal: true

FactoryBot.define do
  factory :paypal_batch do
    date { 2.days.ago.to_date }
  end
end
