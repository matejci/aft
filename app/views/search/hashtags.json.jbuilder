# frozen_string_literal: true

json.total_pages @collection[:total_pages]
json.posts_count @collection[:posts_count]

json.data do
  json.array! @collection[:posts] do |post|
    json.id post.id
    json.description post.description
    json.media_thumbnail_dimensions post.media_thumbnail_dimensions
    json.media_thumbnail post.media_thumbnail
    json.link_title post.link_title
    json.views_count post.views_count
    json.set! :user do
      json.id post.user.id
      json.email post.user.email
      json.phone post.user.phone
      json.display_name post.user.display_name
      json.username post.user.username
      json.profile_image_thumb_url post.user.profile_image_thumb_url
    end
  end
end
