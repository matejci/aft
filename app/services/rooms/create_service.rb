# frozen_string_literal: true

module Rooms
  class CreateService
    def initialize(name:, user:, members:)
      @name = name
      @user = user
      @members = members
    end

    def call
      create_room
    end

    private

    attr_reader :name, :user, :members

    def create_room
      members << user.id.to_s
      user.created_rooms.create!(name: name, members: User.active.where(:id.in => members))
    end
  end
end
