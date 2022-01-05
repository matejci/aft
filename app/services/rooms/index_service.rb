# frozen_string_literal: true

module Rooms
  class IndexService
    PER_PAGE = 10

    def initialize(page:, user:)
      @page = page.presence || 1
      @user = user
    end

    def call
      rooms
    end

    private

    attr_reader :page, :user

    def rooms
      user.rooms.order_by(created_at: 1).skip(calculate_offset).limit(PER_PAGE)
    end

    def calculate_offset
      (page.to_i - 1) * PER_PAGE
    end
  end
end
