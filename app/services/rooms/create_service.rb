# frozen_string_literal: true

module Rooms
  class CreateService
    def initialize(name:, is_public:, members:)
      @name = name
      @is_public = is_public
      @members = members
    end

    def call
      create_room
    end

    private

    attr_reader :name, :is_public, :members

    def create_room
      room = Room.create!(name: name, is_public: is_public, created_by_id: members.last)
      room.members = User.active.where(:id.in => members)
      room
    end
  end
end
