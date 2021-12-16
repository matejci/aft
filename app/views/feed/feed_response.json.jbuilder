# frozen_string_literal: true

json.type @collection[:type]
json.total_pages @collection[:total_pages]

json.data do
  json.array! @collection[:posts], partial: 'posts/custom_posts/custom_item', as: :custom_post
end
