# frozen_string_literal: true

module Rooms
  class AddMembersService
    def initialize(room_id:, member_ids:)
      @room_id = room_id
      @member_ids = member_ids
      @members = nil
    end

    def call
      validate_members
      add_members
    end

    private

    attr_reader :room_id, :member_ids

    def validate_members
      @members = User.active.where(:id.in => member_ids).to_a

      raise ActionController::BadRequest, 'specified members not found' if @members.blank?
    end

    def add_members
      room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless room

      @members.each do |member|
        room.members << member
        room.ex_members.delete(member)
      end

      room.save!

      members = room.members.to_a

      Rooms::MembersThumbService.new(room: room, members: members).call

      update_room_name(room, members)
      room
    end

    def update_room_name(room, members)
      return if room.name.present?

      room.generated_name = members.pluck(:username).uniq.join(', ')
      room.save
    end
  end
end
