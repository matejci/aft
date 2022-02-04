# frozen_string_literal: true

module Search
  class HashtagService < BaseService
    def initialize(query:, page: nil, per_page: nil)
      @query = query
      @page = page
      @per_page = (per_page.presence || PER_PAGE[:search_hashtags]).to_i
    end

    def call
      hashtags
    end

    private

    attr_reader :query, :page, :per_page

    def hashtags
      raise SearchParamMissing, 'Missing query param' if query.blank?

      hashtag = Hashtag.find_by(name: query)
      return { posts: [], posts_count: 0, total_pages: 0 } if hashtag.nil?

      posts_count = hashtag.posts.active.count
      return { posts: [], posts_count: 0, total_pages: 0 } if posts_count.zero?

      posts = hashtag.posts.active.includes(:user).order_by(publish_date: :desc).offset(calculate_offset).limit(per_page)

      { posts: prepare_posts(posts), posts_count: posts_count, total_pages: calculate_total_pages(posts_count) }
    end

    def prepare_posts(posts)
      posts.each_with_object([]) do |post, results|
        results << HashtagPost.new.tap do |cp|
          cp.id = post.id
          cp.description = post.description
          cp.media_thumbnail_dimensions = post.media_thumbnail_dimensions
          cp.media_thumbnail = post.media_thumbnail.url
          cp.link_title = post.link_title
          cp.views_count = post.total_views
          cp.user = prepare_user(post.user)
        end
      end
    end

    def prepare_user(user)
      HashtagUser.new.tap do |cu|
        cu.id = user.id
        cu.email = user.email
        cu.phone = user.phone
        cu.display_name = user.display_name
        cu.username = user.username
        cu.profile_image_thumb_url = user.profile_image.url(:thumb)
      end
    end

    def calculate_offset
      if page.to_i <= 1
        0
      else
        (page.to_i - 1) * per_page
      end
    end

    def calculate_total_pages(items_count)
      (items_count % per_page).zero? ? (items_count / per_page) : (items_count / per_page + 1)
    end
  end
end
