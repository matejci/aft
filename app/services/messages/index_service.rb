# frozen_string_literal: true

module Messages
  class IndexService
    def initialize(room:, page:, per_page:, user:)
      @room = room
      @page = page.presence || 1
      @per_page = per_page.presence || PER_PAGE[:messages]
      @user = user
    end

    def call
      messages
    end

    private

    attr_reader :room, :page, :per_page, :user

    def messages
      num_of_recs = per_page.to_i > 40 ? 40 : per_page.to_i

      messages = room.messages.order(created_at: -1).skip(calculate_offset(num_of_recs)).limit(num_of_recs)
      messages.reverse!
    end

    def calculate_offset(num_of_recs)
      (page.to_i - 1) * num_of_recs
    end
  end
end
