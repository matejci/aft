# frozen_string_literal: true

module Rooms
  class MembersThumbService
    def initialize(room:, members:)
      @room = room
      @members = members
    end

    def call
      reset_members_counters
      update_room_thumbnail
      room.save
      room
    end

    private

    attr_reader :room, :members

    def reset_members_counters
      room.members_count = room.members.count
    end

    def update_room_thumbnail
      room.room_thumb = if room.members_count > 2
        room.members_count
      else
        member = members.find { |m| m.id.to_s != room.created_by_id }
        member.profile_image.url
      end
    end
  end
end
