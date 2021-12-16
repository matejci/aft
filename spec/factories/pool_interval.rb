# frozen_string_literal: true

FactoryBot.define do
  factory :pool_interval do
    pool
    date { Date.current.beginning_of_month }
    watch_time_rate { 1 }
    total_watch_time { 5 }
  end
end
