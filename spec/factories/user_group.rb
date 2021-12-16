# frozen_string_literal: true

FactoryBot.define do
  factory :user_group do
    user
    sequence(:name) { |n| "group #{n}" }
  end
end
