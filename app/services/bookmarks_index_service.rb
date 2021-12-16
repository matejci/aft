# frozen_string_literal: true

class BookmarksIndexService
  def initialize(user:, bookmarks:, page:)
    @user = user
    @bookmarks = bookmarks
    @page = page.presence || 1
  end

  def call
    bookmarked_posts
  end

  private

  attr_reader :user, :bookmarks, :page

  def bookmarked_posts
    return { collection: [], total_pages: 0, type: 'bookmarks' } if bookmarks.blank?

    posts = Post.search('*', **query_options)
    total_pages = posts.total_pages

    data = Posts::CarouselDataService.new(collection: posts, viewer: user).call

    custom_posts = Posts::CarouselBuilderService.new(posts_data: posts,
                                                     takkos_data: data[:takkos],
                                                     users_data: data[:users],
                                                     votes: data[:votes],
                                                     viewer: user,
                                                     viewer_conf: data[:viewer_conf],
                                                     parents_data: data[:parents]).call

    { posts: custom_posts, total_pages: total_pages, type: 'bookmarks' }
  end

  def query_options
    {
      includes: [:feed_item, :parent, :user, :category, :takkos],
      where: { :id.in => bookmarks },
      order: { publish_date: { order: 'desc', unmapped_type: 'long' } },
      page: page,
      per_page: PER_PAGE[:bookmarks]
    }
  end
end
