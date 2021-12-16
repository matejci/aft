# frozen_string_literal: true

FactoryBot.define do
  factory :pool do
    amount { 1000 }
    name { 'one thousand' }
    start_date { Date.current.beginning_of_month }
  end
end
