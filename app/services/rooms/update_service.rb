# frozen_string_literal: true

module Rooms
  class UpdateService
    def initialize(room_id:, name:, user:)
      @room_id = room_id
      @name = name
      @user = user
    end

    def call
      update_room
    end

    private

    attr_reader :room_id, :name, :user

    def update_room
      room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless room
      raise ActionController::BadRequest, "You're not a member of a room" unless room.member_ids.include?(user.id)

      room.update!(name: name, generated_name: nil)
      room
    end
  end
end
