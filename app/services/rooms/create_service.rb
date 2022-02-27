# frozen_string_literal: true

module Rooms
  class CreateService
    def initialize(name:, user:, member_ids:)
      @name = name
      @user = user
      @member_ids = member_ids
      @members = nil
    end

    def call
      validate_members
      create_room
    rescue StandardError => e
      Bugsnag.notify(e)
      raise e
    end

    private

    attr_reader :name, :user, :member_ids

    def create_room
      room_members_hash = {}

      user.rooms.each { |room| room_members_hash[room.id.to_s] = room.member_ids.sort }

      member_sorted_ids = @members.pluck(:id).sort

      room_hash = room_members_hash.find { |_key, val| val == member_sorted_ids }

      room = Room.find(room_hash[0]) if room_hash

      room = if room
        room.update!(name: name, generated_name: generate_name) if name != room.name
        room
      else
        room = user.created_rooms.create!(name: name, generated_name: generate_name, member_ids: member_sorted_ids)
        Rooms::MembersThumbService.new(room: room, members: @members).call
      end

      { room: room, messages: Messages::IndexService.new(room: room, page: 1, per_page: nil, user: user).call, members: @members, ex_members: room.ex_members }
    end

    def validate_members
      raise ActionController::BadRequest, 'You cannot add yourself as a member' if member_ids.size == 1 && member_ids[0] == user.id.to_s

      @members = User.active.where(:id.in => member_ids).to_a

      raise ActionController::BadRequest, 'You need to provide at least one member_id' if @members.blank?

      @members << user
    end

    def generate_name
      return if name.present?

      @members.pluck(:username).uniq.join(', ')
    end
  end
end
