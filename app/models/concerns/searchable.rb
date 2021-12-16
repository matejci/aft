module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search_for(query, *attrs)
      filters = {
                  match: :text_middle,
                  misspellings: { prefix_length: 2 },
                  per_page: 20
                }.merge(*attrs)

      search query, **filters
    end
  end
end
