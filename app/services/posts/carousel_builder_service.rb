# frozen_string_literal: true

# rubocop: disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity, Metrics/ParameterLists
module Posts
  class CarouselBuilderService
    include TakkoStructs

    def initialize(posts_data:, takkos_data:, users_data:, votes:, viewer: nil, viewer_conf: nil, parents_data: nil)
      @posts_data = posts_data
      @takkos_data = takkos_data
      @users_data = users_data
      @votes = votes
      @viewer = viewer
      @viewer_conf = viewer_conf
      @parents_data = parents_data
    end

    def call
      generate_custom_posts
    end

    private

    attr_reader :posts_data, :takkos_data, :users_data, :votes, :viewer, :viewer_conf, :parents_data

    def generate_custom_posts
      posts_data.each_with_object([]) do |post, results|
        cp = CustomPost.new
        cp.post = post
        cp.feed_item = post.feed_item || FeedItem.new
        cp.user = post.user
        cp.category = post.category
        cp.takkos = prepare_takkos(post)
        cp.carousel_muted = viewer_conf.carousel_notifications_blacklist.include?(cp.takkos.first.post.id.to_s) if viewer_conf

        results << cp
      end
    end

    def prepare_takkos(post)
      original_post = post.parent || post
      order = original_post.takko_order
      selected = post
      post_creator = users_data.find { |u| u.id == original_post.user_id }

      takkos = if Permissions::ViewsPermissionService.new(post: original_post, post_creator: post_creator, viewer: viewer).call
        if selected.takko?
          [original_post, sort_takkos(original_post, order), selected, selected.id.to_s].flatten.uniq
        else
          [original_post, sort_takkos(original_post, order)].flatten
        end
      elsif selected.owner?(viewer)
        [original_post, selected]
      else
        []
      end.compact

      takkos.each_with_object([]).with_index do |(takko, takko_results), ind|
        break takko_results if takkos.size == ind + 1 && takkos.last.is_a?(String)

        takko = parents_data.find { |item| item.id.to_s == takko.id.to_s } if takkos.last.is_a?(String) && ind.zero?

        ct = CustomTakko.new
        ct.post = takko
        ct.user = takko.user
        ct.category = takko.category

        if viewer.present?
          original_user = users_data.find { |u| u.id == takko.original_user_id }

          ct.can_takko = Permissions::TakkosPermissionService.new(takko: takko, original_user: original_user, viewer: viewer).call
          ct.voted = find_votes(takko.id)&.last
          ct.bookmarked = viewer_conf.bookmarks.include?(takko.id.to_s)
        end

        ct.takkos_received = takko.takkos_received

        takko_results << ct
      end
    end

    def sort_takkos(original_post, order)
      return unless takkos_data.any? { |takko| takko.parent_id == original_post.id }

      takkos = takkos_data.select { |t| t.parent_id == original_post.id }

      return takkos if takkos.blank?

      takkos = case order
               when :oldest
                 takkos.sort_by(&:publish_date)
               when :newest
                 takkos.sort_by(&:publish_date).reverse
               when :comments
                 takkos.sort_by(&:comments_count).reverse
               when :upvotes
                 takkos.sort_by(&:upvotes_count).reverse
               when :views
                 takkos.sort_by(&:total_views).reverse
      end

      takkos[0..5]
    end

    def find_votes(takko_id)
      votes.find { |v| v[0] == takko_id }
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/ParameterLists
