# frozen_string_literal: true

namespace :categories do
  desc 'Add new/missing categories'
  task add_more: :environment do
    [
      'Animals',
      'Art',
      'Autos & Vehicles',
      'Beauty',
      'Business',
      'Comedy',
      'Dance',
      'Education',
      'Fashion & Style',
      'Film & Animation',
      'Food',
      'Gaming',
      'How To',
      'Music',
      'News',
      'Nonprofits & Activism',
      'People & Blogs',
      'Politics',
      'Science & Tech',
      'Sports',
      'Travel & Events',
      'Vlogging'
    ].each do |name, filename|
      category = Category.find_or_create_by(name: name)
    end

    Rails.cache.delete_matched "categories_with_admin_*"
  end
end
