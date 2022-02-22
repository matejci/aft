# frozen_string_literal: true

module Messages
  class IndexService
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
      messages = room.messages.order(created_at: -1).skip(calculate_offset).limit(PER_PAGE[:messages])
      messages.reverse!
    end

    def calculate_offset
      (page.to_i - 1) * PER_PAGE[:messages]
    end
  end
end
