# frozen_string_literal: true

namespace :app do
  desc 'Add ads for every app configuration'
  task ads: :environment do
    Configuration.update_all(ads: { search_ads_enabled: true, search_ads_frequency: 5, discover_ads_enabled: true, discover_ads_frequency: 7 })
  end
end
