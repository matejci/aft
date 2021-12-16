# frozen_string_literal: true

FactoryBot.define do
  factory :paypal_account do
    user
    sequence(:email) { Faker::Internet.email }
  end
end
