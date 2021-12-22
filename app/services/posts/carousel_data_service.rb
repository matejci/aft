# frozen_string_literal: true

module Posts
  class CarouselDataService
    def initialize(collection:, viewer: nil)
      @collection = collection
      @viewer = viewer
    end

    def call
      prepare_carousel_data
    end

    private

    attr_reader :collection, :viewer

    def prepare_carousel_data
      original_posts_ids = []
      parent_ids = []

      collection.each do |item|
        if item.parent_id.nil?
          original_posts_ids << item.id
        else
          parent_ids << item.original_post_id
        end
      end

      takkos = Post.active.includes(:category, :user, :parent).where(:parent_id.in => (original_posts_ids + parent_ids).uniq).to_a
      parents = Post.includes(:category, :user).where(:_id.in => parent_ids).to_a

      user_ids = (collection.pluck(:user_id, :original_user_id).flatten + takkos.pluck(:user_id)).uniq
      users = User.includes(:blocks, :blocking).where(:_id.in => user_ids).to_a

      if viewer
        votes = viewer.votes.pluck(:post_id, :type)
        viewer_conf = viewer.configuration
      end

      {
        takkos: takkos,
        parents: parents,
        users: users,
        votes: votes,
        viewer_conf: viewer_conf
      }
    end
  end
end
