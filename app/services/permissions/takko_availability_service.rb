# frozen_string_literal: true

module Permissions
  class TakkoAvailabilityService
    def initialize(takko:, takko_creator:, viewer: nil)
      @takko = takko
      @takko_creator = takko_creator
      @viewer = viewer
    end

    def call
      return takko.view_permission == :public if viewer.nil?

      check_availability
    end

    private

    attr_reader :takko, :takko_creator, :viewer

    def check_availability
      takko.active? && !blocked_by_viewer? && !blocked_viewer? && viewer_permitted?
    end

    def viewer_permitted?
      return true if takko.view_permission == :public                                  # takko is public
      return true if takko.user_id == viewer.id || takko.original_user_id == viewer.id # viewer is creator of the takko or the original post
      return false if takko.view_permission == :private                                # takko is private

      takko_creator.followers_ids.include?(viewer.id.to_s)                             # viewer is a follower of a user who created takko
    end

    def blocked_by_viewer?
      takko_creator.blocks.pluck(:blocked_by_id).include?(viewer.id)
    end

    def blocked_viewer?
      takko_creator.blocking.pluck(:user_id).include?(viewer.id)
    end
  end
end
