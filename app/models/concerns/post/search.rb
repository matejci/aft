# frozen_string_literal: true

class Post
  module Search
    extend ActiveSupport::Concern
    include Searchable

    included do
      searchkick text_middle: %i[description username hashtags],
        callbacks: false

      scope :search_import, -> { active.includes(:hashtags, :parent, :user) }

      def self.search_for(query, attrs)
        filters = { fields: [:description, :username, { hashtags: :exact }] }
        filters[:where] = viewer_filter(attrs.delete(:viewer_id)) if attrs.key?(:viewer_id)

        super(query, filters.deep_merge(attrs))
      end

      def self.viewer_filter(viewer_id)
        if viewer_id.present?
          {
            _or: [
              { user_id: viewer_id }, { permitted: viewer_id }, { view_public: true }
            ],
            blocked: { not: viewer_id }
          }
        else
          { view_public: true }
        end
      end
    end

    def search_data
      {
        description: description, publish_date: publish_date, user_id: user_id.to_s, category_id: category_id.to_s,
        view_public: view_public?, original_post_id: original_post_id.to_s
      }.merge(
        search_hashtags, search_username, search_blocked_filter, search_permitted_filter, search_sort
      )
    end

    def should_index?
      active? && valid?
    end

    private

    def search_hashtags
      { hashtags: hashtags.map(&:name) }
    end

    def search_username
      { username: user.username }
    end

    def search_blocked_filter
      { blocked: user.block_user_ids.map(&:to_s) }
    end

    def search_permitted_filter
      { permitted: permitted_user_ids.map(&:to_s) }
    end

    def search_sort
      {
        comments_count: comments_count,
        upvotes_count: upvotes_count,
        total_views: total_views
      }
    end
  end
end
