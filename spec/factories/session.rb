# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    app
    user
    user_agent   { 'takkoPhone01' }
    ip_address   { '1.2.3.4' }
    access_token { 'abcd' }
    token { '10101010' }
    live { true }
  end
end
