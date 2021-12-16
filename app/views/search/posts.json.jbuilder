# frozen_string_literal: true

json.total_pages @collection[:total_pages]

json.data do
  json.array! @collection[:data], partial: 'posts/custom_posts/custom_item', as: :custom_post
end
