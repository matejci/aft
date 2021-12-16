# frozen_string_literal: true

namespace :user do
  desc 'Create configuration for every user'
  task config_init: :environment do
    User.all.no_timeout.each do |u|
      conf = u.build_configuration
      conf.ads = { search_ads_enabled: true, search_ads_frequency: 5, discover_ads_enabled: true, discover_ads_frequency: 7 }
      conf.save
    end
  end
end
