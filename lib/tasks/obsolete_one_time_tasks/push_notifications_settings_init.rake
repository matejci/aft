# frozen_string_literal: true

namespace :user do
  desc "Initialize users' push notifications settings"
  task push_notifications_settings_init: :environment do
    UserConfiguration.update_all(push_notifications_settings: DEFAULT_PUSH_NOTIFICATIONS_SETTINGS)

    puts 'Finished.'
  end
end
