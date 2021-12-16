# frozen_string_literal: true

module Users
  class ConfigurationInitService
    def initialize(user:)
      @user = user
    end

    def call
      config_init
    end

    private

    attr_reader :user

    def config_init
      user.create_configuration(ads: ads, support: support)
    end

    def ads
      {
        search_ads_enabled: true,
        search_ads_frequency: 20,
        discover_ads_enabled: true,
        discover_ads_frequency: 20
      }
    end

    def support
      {
        login_screen_chat_enabled: true,
        profile_dashboard_chat_enabled: true
      }
    end
  end
end
