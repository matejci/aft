# frozen_string_literal: true

module Rooms
  class AddMemberService
    def initialize(room_id:, member_id:)
      @room_id = room_id
      @member_id = member_id
      @member = nil
    end

    def call
      validate_member
      add_member
    end

    private

    attr_reader :room_id, :member_id

    def add_member
      room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless room

      room.member_ids << @member.id
      room.save

      members = room.members.to_a

      Rooms::MembersThumbService.new(room: room, members: members).call

      update_room_name(room, members)
      room
    end

    def validate_member
      @member = User.active.find(member_id)

      raise ActionController::BadRequest, 'Wrong member_id' unless @member
    end

    def update_room_name(room, members)
      return if room.name.present?

      room.generated_name = members.pluck(:username).uniq.join(', ')
      room.save
    end
  end
end
