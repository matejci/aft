# frozen_string_literal: true

# post info
json.extract! takko, :id, :link, :publish_date, :description, :media_file_url, :video_length, :deleted, :animated_cover_url

json.published time_ago_in_words(takko.publish_date)

# to avoid ActionView::Template::Error (can't dump anonymous class)
json.media_thumbnail takko.media_thumbnail.as_json
json.media_thumbnail_dimensions takko.media_thumbnail_dimensions
json.master_playlist "#{takko.media_file_url}_playlist.m3u8"

# owner info
json.user takko.user, partial: 'users/tag', as: :user

# category info
json.category do
  json.call(takko.category, :id, :name, :link)
end

# counts
json.call(takko, :total_views, :comments_count, :upvotes_count, :counted_watchtime)

# viewer specific info
json.available takko.available?(@current_user)

if @current_user
  json.can_comment takko.allow_comments
  json.can_takko   takko.can_takko?(@current_user)
  json.voted       Vote.find_for(takko, @current_user)
end
