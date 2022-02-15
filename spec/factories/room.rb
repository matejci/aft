# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    name { nil }
    last_read_messages { {} }
    member_ids { [] }
  end
end
