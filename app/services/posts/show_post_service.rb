# frozen_string_literal: true

module Posts
  class ShowPostService
    def initialize(id:, link:, viewer:)
      @id = id
      @link = link
      @viewer = viewer
    end

    def call
      load_post
    end

    private

    attr_reader :id, :link, :viewer

    def load_post
      post = Post.active.includes(:user, :category, :feed_item, :takkos, :parent).any_of({ id: id }, { link: link }).first

      return unless post

      Rails.cache.fetch("post_#{post.id}_#{post.updated_at.to_i}") do
        collection = [post]

        data = Posts::CarouselDataService.new(collection: collection, viewer: viewer).call

        Posts::CarouselBuilderService.new(posts_data: collection,
                                          takkos_data: data[:takkos],
                                          users_data: data[:users],
                                          votes: data[:votes],
                                          viewer: viewer,
                                          viewer_conf: data[:viewer_conf],
                                          parents_data: data[:parents]).call.first
      end
    end
  end
end
