# frozen_string_literal: true

# rubocop: disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
module Feeds
  class ProfileService
    def initialize(posts_type:, user:, viewer:, order:, page:)
      @posts_type = posts_type
      @user = user
      @viewer = viewer
      @order = order
      @page = page
    end

    def call
      profile_posts
    end

    private

    attr_reader :posts_type, :user, :viewer, :order, :page

    def profile_posts
      custom_posts = generate_posts(prepare_posts.to_a)

      { posts: custom_posts }
    end

    def prepare_posts
      query = Post.active.includes(:feed_item, :category, :takkos, :parent, :user).where(user_id: user.id)

      query = case posts_type
              when 'private'
                permissions = if user == viewer
                  [:private, :followees]
                elsif user.followees.exclude?(viewer)
                  []
                else
                  [:followees]
                end

                post_ids = Post.active.original.where(:view_permission.in => permissions, user_id: user.id).pluck(:id)
                takkos = Post.active.takko.where(user_id: user.id, :view_permission.in => permissions).pluck(:parent_id, :id)
                takko_hash = Hash.new { |h, k| h[k] = [] }

                takkos.each do |takko|
                  post_ids.delete(takko.first) if post_ids.include?(takko.first)
                  next if takko_hash.key?(takko.first)

                  takko_hash[takko.first] << takko.last
                end

                query.where(:_id.in => (post_ids + takko_hash.values).flatten)
              when 'takkos'
                query.takko.where(view_permission: :public, own_takko: false)
              when 'posts'
                query.original.where(view_permission: :public)
      end

      query.post_order(order.presence).page(page.presence || 1).per(PER_PAGE[:profile_feed])
    end

    def generate_posts(collection)
      return [] if collection.blank?

      data = Posts::CarouselDataService.new(collection: collection, viewer: viewer).call
      Posts::CarouselBuilderService.new(posts_data: collection,
                                        takkos_data: data[:takkos],
                                        users_data: data[:users],
                                        votes: data[:votes],
                                        viewer: viewer,
                                        viewer_conf: data[:viewer_conf],
                                        parents_data: data[:parents]).call
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
