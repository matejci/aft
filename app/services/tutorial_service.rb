# frozen_string_literal: true

class TutorialService
  include TakkoStructs

  PER_PAGE = 5

  def initialize(page_num:)
    @page_num = page_num || 1
  end

  def call
    tutorial_items
  end

  private

  attr_reader :page_num

  def tutorial_items
    category = Category.takko_tutorial_category

    posts = Post.active.includes(:feed_item, :user, :category, :takkos)
                .where(category_id: category.id, parent_id: nil)
                .where.not(title: 'INTRO VIDEO').order(created_at: -1).page(page_num).per(PER_PAGE)

    total_pages = posts.total_pages

    results = []

    posts.each do |post|
      cp = CustomPost.new
      cp.post = post
      cp.feed_item = post.feed_item || FeedItem.new
      cp.user = post.user
      cp.category = post.category
      cp.takkos = prepare_takkos(post)

      results << cp
    end

    { posts: results, total_pages: total_pages, type: 'tutorial' }
  end

  def prepare_takkos(post)
    post.takkos.active.each_with_object([]) do |takko, takko_results|
      ct = CustomTakko.new
      ct.post = takko
      ct.user = takko.user
      ct.category = takko.category

      takko_results << ct
    end
  end
end
