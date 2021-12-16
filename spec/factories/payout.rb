# frozen_string_literal: true

FactoryBot.define do
  factory :payout do
    user
    pool_interval
    watch_time { 10 }
  end
end
