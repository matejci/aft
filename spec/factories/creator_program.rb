# frozen_string_literal: true

FactoryBot.define do
  factory :creator_program do
    active { true }
    threshold { 2 }
    participants { [] }
  end
end
