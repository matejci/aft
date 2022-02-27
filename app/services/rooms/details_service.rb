# frozen_string_literal: true

module Rooms
  class DetailsService
    def initialize(room_id:)
      @room_id = room_id
    end

    def call
      room_details
    end

    private

    attr_reader :room_id

    def room_details
      room = Room.includes(:members, :ex_members, :messages).find(room_id)

      raise ActionController::BadRequest, 'Wrong room id' unless room

      { room: room, messages: prepare_messages(room.messages), members: room.members, ex_members: room.ex_members }
    end

    def prepare_messages(messages)
      messages = messages.order(created_at: -1).offset(0).limit(PER_PAGE[:messages])
      messages.reverse!
    end
  end
end
