# frozen_string_literal: true

module Rooms
  class SuggestedColleaguesService
    def initialize(user:)
      @user = user
    end

    def call
      suggested_colleagues
    end

    private

    attr_reader :user

    def suggested_colleagues
      room_members = user.rooms.pluck(:member_ids).flatten.uniq.map(&:to_s)
      room_members = room_members.reject { |m| m == user.id.to_s }

      ff_to_add = 10 - room_members.size

      room_members << user.followees_ids.shuffle.take(ff_to_add / 2)

      room_members = room_members.flatten
      room_members << user.followers_ids.shuffle.take(10 - room_members.size)

      room_members = room_members.flatten.uniq

      User.active.where(:id.in => room_members)
    end
  end
end
