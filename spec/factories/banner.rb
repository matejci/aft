# frozen_string_literal: true

FactoryBot.define do
  factory :banner do
    sequence(:order) { |n| n }
    sequence(:link) { |n| "link_#{n}" }
    image { File.open('public/takko.png') }
  end
end
