# frozen_string_literal: true

module PushNotifications
  class UpdateService
    PUSH_NOTIFICATIONS_ALLOWED_VALUES = %w[everyone following on off].freeze

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      update_push_notifications_settings
    end

    private

    attr_reader :user, :params

    def update_push_notifications_settings
      user_conf = user.configuration
      settings = user_conf.push_notifications_settings

      params.each do |param|
        case param.first
        when 'upvoted', 'added_takko', 'commented', 'mentioned'
          allowed_values = PUSH_NOTIFICATIONS_ALLOWED_VALUES - ['on']
          raise_error(param, allowed_values) unless param.last.in?(allowed_values)
        when 'followed', 'payout', 'followee_posted'
          allowed_values = PUSH_NOTIFICATIONS_ALLOWED_VALUES - %w[everyone following]
          raise_error(param, allowed_values) unless param.last.in?(allowed_values)
        end

        settings[param.first] = param.last
      end

      user_conf.save!
      user_conf.push_notifications_settings
    end

    def raise_error(param, allowed_values)
      raise ActionController::BadRequest, "Value '#{param.last}' not allowed for #{param.first} attribute. Allowed values: #{allowed_values.join(', ')}"
    end
  end
end
