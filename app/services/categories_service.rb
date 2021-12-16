# frozen_string_literal: true

class CategoriesService
  def initialize(admin:)
    @admin = admin
  end

  def call
    categories
  end

  private

  attr_reader :admin

  def categories
    Rails.cache.fetch("categories_with_admin_#{admin}") do
      categories = admin ? Category.active.asc(:name) : Category.active.without_tutorial.asc(:name)

      categories.each_with_object([]) do |category, results|
        if category.link != 'takko-tutorial'
          category.icon = ActionController::Base.helpers.asset_path("categories/#{category.link}.png")
          category.filter_active_icon = ActionController::Base.helpers.asset_path("categories/filter/active/#{category.link}.png")
          category.filter_inactive_icon = ActionController::Base.helpers.asset_path("categories/filter/inactive/#{category.link}.png")
        end

        results << category
      end
    end
  end
end
