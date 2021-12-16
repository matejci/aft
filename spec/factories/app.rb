# frozen_string_literal: true

FactoryBot.define do
  factory :app do
    app_id { SecureRandom.random_number(10_000_000_000_000_000_000..99_999_999_999_999_999_999) }
    public_key { SecureRandom.hex(25) }
    key { SecureRandom.urlsafe_base64(50, false) }
    secret { SecureRandom.urlsafe_base64(50, false) }
    name        { 'test' }
    email       { 'test@email.com' }
    description { 'test' }
    app_type    { 'ios' }
    status      { true }
  end
end
