# frozen_string_literal: true

module Feeds
  class BaseService
    def initialize
      raise 'not implemented'
    end

    private

    def default_query_options(page_number:, per_page:)
      {
        includes: [:parent, :user, :category, :takkos],
        where: match_query,
        order: { publish_date: { order: 'desc', unmapped_type: 'long' } },
        page: page_number,
        per_page: per_page,
        body_options: { collapse: { field: 'original_post_id' } }
      }
    end

    def match_query
      query = {}
      query[:category_id] = { not: Category.aft_tutorial_category.id.to_s } if feed_type != 'home'
      query.merge!(send("#{feed_type}_filters"))
      query[:blocked] = { not: user_id } if user_id.present?
      query
    end

    def permitted_filters
      permitted = if user_id.present?
        [{ view_public: true }, { user_id: user_id }, { permitted: user_id }]
      else
        [{ view_public: true }]
      end

      { _or: permitted }
    end
  end
end
