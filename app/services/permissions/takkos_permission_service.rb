# frozen_string_literal: true

module Permissions
  class TakkosPermissionService
    def initialize(takko:, original_user:, viewer: nil)
      @takko = takko
      @original_user = original_user
      @viewer = viewer
    end

    def call
      can_takko?
    end

    private

    attr_reader :takko, :original_user, :viewer

    def can_takko?
      return true if takko.takko_permission == :public || takko.user_id == viewer&.id # takko permissions are public or viewer is takko creator
      return permitted_user_ids.include?(viewer.id.to_s) if viewer

      false
    end

    def permitted_user_ids
      case takko.takko_permission
      when :followees
        [original_user.id.to_s, original_user.followees_ids].flatten
      when :custom
        takkoer_ids = takko.parent_id.nil? ? takko.takkoer_ids : takko.parent.takkoer_ids

        [original_user.id.to_s, takkoer_ids].flatten
      else
        []
      end
    end
  end
end
