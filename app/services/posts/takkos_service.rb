# frozen_string_literal: true

module Posts
  class TakkosService
    PER_PAGE = 7

    def initialize(post:, params:)
      @post = post
      @params = params
    end

    def call
      takkos
    end

    private

    attr_reader :post, :params

    def takkos
      takkos = post.takkos.active.includes(:user, :category, :feed_item)
                   .post_order(params[:order] || post.takko_order)
                   .page(params[:page].presence || 1)
                   .per(params[:per_page].presence || PER_PAGE)

      total_pages = takkos.total_pages

      takkos = takkos.to_a.prepend(post) if params[:page].to_i <= 1

      { post: post, data: takkos, total_pages: total_pages, takkos_count: post.takkos.active.size }
    end
  end
end
