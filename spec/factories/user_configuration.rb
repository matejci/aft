# frozen_string_literal: true

FactoryBot.define do
  factory :user_configuration do
    user
    ads { { search_ads_enabled: true, search_ads_frequency: 5, discover_ads_enabled: true, discover_ads_frequency: 7 } }
    app_tracking_transparency { :undetermined }
    app_tracking_transparency_recorded_at { Time.current }
    watched_items { [] }
    push_notifications_settings { DEFAULT_PUSH_NOTIFICATIONS_SETTINGS }
    bookmarks { [] }
    badges { [] }
  end
end
