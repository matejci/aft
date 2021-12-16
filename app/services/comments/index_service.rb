# frozen_string_literal: true

module Comments
  class IndexService
    PER_PAGE = 10

    def initialize(user:, params:, post:)
      @user = user
      @params = params
      @post = post
    end

    def call
      comments
    end

    private

    attr_reader :user, :params, :post

    def comments
      comments = post.comments.not_blocked(user).active
      comments_count = comments.size
      comments = comments.order_by(created_at: :desc).page(params[:page].presence || 1).per(params[:per_page].presence || PER_PAGE)

      { comments: comments, total_pages: comments.total_pages, comments_count: comments_count }
    end
  end
end
