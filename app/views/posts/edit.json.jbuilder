# frozen_string_literal: true

json.extract! @post, :id, :title, :description, :category_id, :media_file_url, :video_length, :allow_comments,
              :view_permission, :takko_permission, :takko_order, :animated_cover_url, :animated_cover_offset

json.media_thumbnail @post.media_thumbnail.as_json
json.media_thumbnail_dimensions @post.media_thumbnail_dimensions
