# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { 'general' }

    trait :tutorial do
      name { 'Aft Tutorial' }
      link { 'aft-tutorial' }
    end
  end
end
