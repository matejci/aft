# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    invitation

    dob { 20.years.ago }
    password { '123456' }
    completed_signup { true }

    sequence(:phone)        { "+1-#{Faker::PhoneNumber.cell_phone.delete('^0-9')}" }
    sequence(:email)        { Faker::Internet.email }
    sequence(:username)     { Faker::Name.name.parameterize.underscore }
    sequence(:display_name) { Faker::Name.name }
    counted_watchtime { rand(1..100) }
    comments_count { rand(1..100) }
  end
end
