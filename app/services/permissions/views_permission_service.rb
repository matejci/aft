# frozen_string_literal: true

module Permissions
  class ViewsPermissionService
    def initialize(post:, post_creator:, viewer: nil)
      @post = post
      @post_creator = post_creator
      @viewer = viewer
    end

    def call
      can_view?
    end

    private

    attr_reader :post, :post_creator, :viewer

    def can_view?
      return true if post.view_permission == :public || post.user_id == viewer&.id
      return permitted_user_ids.include?(viewer.id.to_s) if viewer

      false
    end

    def permitted_user_ids
      case post.view_permission
      when :followees
        [post_creator.id.to_s, post_creator.followees_ids].flatten
      when :custom
        user_ids = post.parent_id.nil? ? post.viewer_ids : post.parent.viewer_ids

        [post_creator.id.to_s, user_ids].flatten
      else
        []
      end
    end
  end
end
