# frozen_string_literal: true

class User
  module Search
    extend ActiveSupport::Concern
    include Searchable

    included do
      searchkick text_middle: [:username, :alias_usernames, :display_name, :email, :phone],
                 word_start: [:username],
                 callbacks: false

      scope :search_import, -> { active }

      after_save :reindex,       if: :searchable_fields_changed?
      after_save :reindex_posts, if: :username_changed?

      after_touch   :reindex, :reindex_posts # when follow/block gets saved/destroyed
      after_destroy :reindex

      def self.search_for(query, attrs)
        filters = { fields: ['username^2', 'alias_usernames^2', :display_name] }.merge(attrs)

        if (viewer_id = filters.delete(:viewer_id))
          filters = filters.deep_merge(where: { blocked: { not: viewer_id } })
        end

        super(query, filters)
      end
    end

    def force_searchable(searchable)
      self.force_index = searchable
      save(validate: false)
    end

    def search_data
      {
        id: id,
        username: username,
        email: email,
        phone: phone,
        display_name: display_name,
        blocked: block_user_ids.map(&:to_s)
      }.merge(search_alias_usernames)
    end

    def should_index?
      active_account? && (!takko_managed? || (takko_managed? && force_index?))
    end

    private

    def reindex_posts
      events = []

      events << :username_change if username_changed?
      events << :block           if block_updated_at_changed?
      events << :follow          if follow_updated_at_changed?

      events.each { |e| PostsReindexer.perform_later(user_id: id.to_s, event: e) }
    end

    def search_alias_usernames
      { alias_usernames: usernames.alias_set.pluck(:name) }
    end

    def searchable_fields_changed?
      (changes.keys & %w[username display_name force_index email phone]).any?
    end
  end
end
