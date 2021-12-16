# frozen_string_literal: true

module Admin
  class CuratedPostsService
    PER_PAGE = 5

    def initialize(page:)
      @page = page.to_i < 1 ? 1 : page.to_i
    end

    def call
      curated_posts
    end

    private

    attr_reader :page

    def curated_posts
      curated_posts = App.find_by(app_type: :ios).configuration.curated_posts
      Post.includes(:user).where(:_id.in => curated_posts).page(page).per(PER_PAGE)
    end
  end
end
