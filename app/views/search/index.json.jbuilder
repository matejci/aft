# frozen_string_literal: true

if @collection[:cached] == true
  json.users_total_pages @collection.dig(:users, 'total_pages')
  json.posts_total_pages @collection.dig(:posts, 'total_pages')

  json.users { json.array! @collection.dig(:users, 'data'), partial: 'cached_users', as: :user }
  json.posts { json.array! @collection.dig(:posts, 'data'), partial: 'posts/custom_posts/custom_cached_item', as: :custom_post }
else
  json.users_total_pages @collection.dig(:users, :total_pages)
  json.posts_total_pages @collection.dig(:posts, :total_pages)

  json.users { json.array! @collection.dig(:users, :data), partial: 'users', as: :user }
  json.posts { json.array! @collection.dig(:posts, :data), partial: 'posts/custom_posts/custom_item', as: :custom_post }
end
