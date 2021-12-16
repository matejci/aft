# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { 'general' }

    trait :tutorial do
      name { 'Takko Tutorial' }
      link { 'takko-tutorial' }
    end
  end
end
