# frozen_string_literal: true

FactoryBot.define do
  factory :configuration do
    app
    ads { { search_ads_enabled: false, search_ads_frequency: 10, discover_ads_enabled: true, discover_ads_frequency: 7 } }
    post_boost { { post_ids: [], boost_value: 1.0, expires_at: Time.current } }
  end
end
