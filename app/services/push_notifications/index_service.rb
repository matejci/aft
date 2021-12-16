# frozen_string_literal: true

module PushNotifications
  class IndexService
    def initialize(user:, page:)
      @user = user
      @page = page.presence || 1
    end

    def call
      notifications
    end

    private

    attr_reader :user, :page

    def notifications
      Notification.for(user).without_payout.includes(:notifiable, :actor).last_three_month.desc(:created_at).page(page)
    end
  end
end
