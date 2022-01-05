# frozen_string_literal: true

module Messages
  class IndexService
    PER_PAGE = 10

    def initialize(room:, page:, user:)
      @room = room
      @page = page.presence || 1
      @user = user
    end

    def call
      messages
    end

    private

    attr_reader :room, :page, :user

    def messages
      room.messages.order_by(created_at: -1).skip(calculate_offset).limit(PER_PAGE)
    end

    def calculate_offset
      (page.to_i - 1) * PER_PAGE
    end
  end
end
