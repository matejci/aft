# frozen_string_literal: true

class Post
  module Permission
    extend ActiveSupport::Concern

    OPTIONS = %i[public followees private custom].freeze

    included do
      enum :view_permission,  OPTIONS, prefix: :view
      enum :takko_permission, OPTIONS, prefix: :takko

      field :viewer_ids,  type: Array
      field :takkoer_ids, type: Array

      # original user determines the permitted users
      delegate :followees_ids, to: :original_user, prefix: :ou # cached method on user

      before_validation :set_default

      validates_with TakkoPermissionValidator, if: :takko?

      with_options if: :original? do
        validates_with PostPermissionValidator

        validate :valid_takko_rule, if: :takko_permission_changed?

        before_save :persist_permissions
        before_save :reset_permitted_user_ids
        after_save  :update_permission_cache
        after_save  :update_takkos
      end
    end

    class_methods do
      def permission_set_by(user)
        where(original_user: user).in(view_permission: %i[followees private])
      end

      def permitted_user_ids(parent_id, action = :view)
        Rails.cache.fetch("#{parent_id}/#{action}er_ids") do
          Post.find(parent_id).send("#{action}er_ids")
        end
      end
    end

    def available?(other_user = nil)
      active? && permitted?(other_user) && !user.blocked_or_blocked_by?(other_user)
    end

    def can_takko?(other_user)
      permitted?(other_user, :takko)
    end

    def owner?(other_user = nil)
      user_id == other_user&.id
    end

    # permitted users

    def permitted?(other_user, action = :view)
      if send("#{action}_public?") || owner?(other_user)
        true
      elsif other_user.present?
        permitted_user_ids(action).include?(other_user.id.to_s)
      else
        false
      end
    end

    def permitted_user_ids(action = :view)
      # WARNING: array should only contain string, NO BSON
      if send("#{action}_followees?")
        [original_user_id.to_s, *ou_followees_ids]
      elsif send("#{action}_custom?")
        [original_user_id.to_s, *Post.permitted_user_ids(original_post_id, action)]
      else
        []
      end
    end

    private

    # default

    def set_default
      if takko?
        self.takko_permission ||= parent.takko_permission
        self.view_permission  ||= parent.view_permission
      else
        self.takko_permission ||= :public
        self.view_permission  ||= :public
      end
    end

    # validations

    def valid_takko_rule
      if view_followees? && takko_public?
        errors.add(:takko_permission, 'only followees can view your post')
      elsif view_private? && !takko_private?
        errors.add(:takko_permission, 'only you can view your post')
      end
    end

    # callbacks

    def persist_permissions
      return unless archiving

      if takko_followees?
        self.takkoer_ids = permitted_user_ids(:takko) - [user_id.to_s]
        self.takko_permission = :custom
      end

      return unless view_followees?

      self.viewer_ids = permitted_user_ids - [user_id.to_s]
      self.view_permission = :custom
    end

    def reset_permitted_user_ids
      self.takkoer_ids = nil if takko_permission_changed? && !takko_custom?
      self.viewer_ids  = nil if view_permission_changed?  && !view_custom?
    end

    def update_permission_cache
      Rails.cache.write("#{id}/takkoer_ids", takkoer_ids) if takko_custom? && takkoer_ids_changed?
      Rails.cache.write("#{id}/viewer_ids",  viewer_ids)  if view_custom?  && viewer_ids_changed?
    end

    def update_takkos
      takkos.set(takko_permission: takko_permission) if takko_permission_changed?
      takkos.set(view_permission:  view_permission)  if view_permission_changed?
    end
  end
end
