# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    content { Faker::ChuckNorris.fact }
    message_type { 'text' }
    room_id { nil }
    sender_id { nil }
  end
end
