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

      raise ActionController::BadRequest, 'specified member(s) not found' if @members.blank?
    end

    def add_members
      room = Room.find(room_id)

      raise ActionController::BadRequest, 'Wrong room_id' unless room

      # TODO, filter out users that are already members?

      @members.each do |member|
        room.members << member
        room.ex_members.delete(member)
      end

      room.save!

      members = room.members.to_a

      Rooms::MembersThumbService.new(room: room, members: members).call

      update_room_name(room, members)
      broadcast_member_joined(room)

      room
    end

    def update_room_name(room, members)
      return if room.name.present?

      room.generated_name = members.pluck(:username).uniq.join(', ')
      room.save
    end

    def broadcast_member_joined(room)
      broadcast_data = {
        room: {
          id: room.id.to_s,
          name: room.name,
          generated_name: room.generated_name,
          created_by_id: room.created_by_id,
          created_at: room.created_at,
          updated_at: room.updated_at,
          last_read_messages: room.last_read_messages,
          members_count: room.members_count,
          room_thumb: room.room_thumb
        },
        joined_members: @members.map do |member|
          {
            id: member.id.to_s,
            username: member.username,
            display_name: member.display_name,
            email: member.email,
            phone: member.phone,
            verified: member.verified,
            profile_thumb_url: member.profile_image.url,
            first_name: member.first_name,
            last_name: member.last_name
          }
        end
      }

      WsBroadcastService.new(broadcaster: room_id, data: broadcast_data, type: 'UserJoined').call
    end
  end
end
