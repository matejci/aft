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
      room = Room.includes(:members, :messages).find(room_id)

      raise ActionController::BadRequest, 'Wrong room id' unless room

      { room: room, messages: room.messages.order(created_at: -1).offset(0).limit(20), members: room.members }
    end
  end
end
