# frozen_string_literal: true

namespace :remote_config do
  desc 'Add support key for every app and user configuration'
  task add_support: :environment do
    support_hash = { login_screen_chat_enabled: true, profile_dashboard_chat_enabled: true }
    Configuration.update_all(support: support_hash)
    UserConfiguration.update_all(support: support_hash)
  end
end
