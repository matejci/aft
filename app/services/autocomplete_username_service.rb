# frozen_string_literal: true

class AutocompleteUsernameService
  def initialize(user:, post_id:, query:)
    @user = user
    @post = Post.active.find(post_id) if post_id.present?
    @query = query.presence || '*'
  end

  def call
    users
  end

  private

  attr_reader :post, :user, :query

  def users
    User.search(query, **build_filters)
  end

  def build_filters
    filters = {
      fields: [:username],
      match: :word_start,
      misspellings: false,
      limit: 50,
      boost_where: { id: [] },
      order: { _score: :desc, username: :asc }
    }

    if post.present?
      filters[:boost_where][:id].concat([
                                          { value: post.user_id.to_s, factor: 100 },
                                          { value: post.comments.pluck(:user_id).map(&:to_s), factor: 5 }
                                        ])
    end

    if user.present?
      filters[:where] = { id: { not: user.id.to_s }, blocked: { not: user.id.to_s } }

      filters[:boost_where][:id].concat([
                                          { value: user.followees_ids, factor: 30 },
                                          { value: user.followers_ids, factor: 15 }
                                        ])
    end

    filters
  end
end
