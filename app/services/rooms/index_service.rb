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
      rooms = user.rooms.order_by(created_at: 1).skip(calculate_offset).limit(PER_PAGE).to_a

      # eager loading of messages might be inefficient in this case, since Room could potentially have a looot of messages
      # because of that we're going to lazy load last message for every room...(1 query per room, maximum around 11 queries )
      # if this become slow in the future, we're going to cache it or find a better solution

      rooms.each do |room|
        msg = room.messages.last

        room.last_message = if msg.present?
          {
            id: msg.id.to_s,
            content: msg.content,
            message_type: msg.message_type,
            sender_id: msg.sender_id.to_s,
            created_at: msg.created_at,
            updated_at: msg.updated_at
          }
        else
          {}
        end
      end
    end

    def calculate_offset
      (page.to_i - 1) * PER_PAGE
    end
  end
end
