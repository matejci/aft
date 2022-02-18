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
      raise ActionController::BadRequest, 'Something went wrong, please contact AFT admin'
    end

    private

    attr_reader :name, :user, :member_ids

    def create_room
      room = user.created_rooms.create!(name: name, generated_name: generate_name, member_ids: @members.pluck(:id))

      Rooms::MembersThumbService.new(room: room, members: @members).call
    end

    def validate_members
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
