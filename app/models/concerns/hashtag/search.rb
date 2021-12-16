# frozen_string_literal: true

class Hashtag
  module Search
    extend ActiveSupport::Concern

    included do
      searchkick word_start: [:name], callbacks: :async

      after_save :reindex_posts, if: :name_changed?

      after_destroy :reindex_posts
    end

    def search_data
      { name: name, popularity: comment_ids.length + post_ids.length }
    end

    private

    def reindex_posts
      posts.reindex(:search_hashtags)
    end
  end
end
