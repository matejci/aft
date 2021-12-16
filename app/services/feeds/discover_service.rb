# frozen_string_literal: true

module Feeds
  class DiscoverService
    def initialize(session:, page_number:, app_id:)
      @session = session
      @viewer = session.user
      @viewer_id = @viewer.id.to_s if @viewer.present?
      @page_number = page_number.presence || '1'
      @app_id = app_id
    end

    def call
      discover_feed
    end

    private

    attr_reader :session, :viewer, :viewer_id, :page_number, :app_id

    def discover_feed
      generate_feed(**prepare_data)
    end

    def prepare_data
      curated_posts_ids = App.find_by(app_id: app_id)&.configuration&.curated_posts

      watched_ids = if viewer.present?
        viewer.configuration.watched_items.uniq
      else
        ViewTracking.where(session_id: session.id).distinct(:post_id)
      end

      post_ids = curated_posts_ids - watched_ids

      return { collection: [], total_pages: 0, type: 'discover' } if post_ids.empty?

      posts = Post.active.includes(:user, :category, :feed_item, :takkos, :parent).where(:id.in => post_ids)
      posts = posts.where.not(:user_id.in => viewer.block_user_ids) if viewer
      posts = posts.page(page_number).per(PER_PAGE[:discover_feed])

      total_pages = posts.total_pages
      posts = posts.shuffle

      { collection: posts.to_a, total_pages: total_pages, type: 'discover' }
    end

    def generate_feed(collection:, total_pages:, type:)
      return { posts: [], total_pages: 0, type: type } if collection.blank?

      data = Posts::CarouselDataService.new(collection: collection, viewer: viewer).call
      custom_posts = Posts::CarouselBuilderService.new(posts_data: collection,
                                                       takkos_data: data[:takkos],
                                                       users_data: data[:users],
                                                       votes: data[:votes],
                                                       viewer: viewer,
                                                       viewer_conf: data[:viewer_conf],
                                                       parents_data: data[:parents]).call

      { posts: custom_posts, total_pages: total_pages, type: type }
    end
  end
end
