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
      admin ? Category.active.asc(:name) : Category.active.without_tutorial.asc(:name)
    end
  end
end
