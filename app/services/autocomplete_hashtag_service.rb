# frozen_string_literal: true

class AutocompleteHashtagService
  def initialize(query:)
    @query = query.presence || '*'
  end

  def call
    hashtags.map(&:name)
  end

  private

  attr_reader :query

  def hashtags
    Hashtag.search(
      query,
      **{
        fields: [:name], match: :word_start, misspellings: false, load: false,
        order: { _score: :desc, popularity: :desc, name: :asc }, limit: 50
      }
    )
  end
end
