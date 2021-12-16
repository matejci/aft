# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    user
    post

    text { Faker::ChuckNorris.fact }
    link { Faker::Internet.url }
  end
end
