# frozen_string_literal: true

json.extract! @post, :id, :link, :title, :publish_date, :description, :media_file_url, :video_length, :deleted, :video_transcoded, :media_thumbnail_dimensions, :animated_cover_url, :media_type

json.published time_ago_in_words(@post.publish_date)

json.media_thumbnail @post.media_thumbnail.as_json
json.master_playlist "#{@post.media_file_url}_playlist.m3u8"

# owner info
json.user @post.user, partial: 'users/tag', as: :user


# category info
json.category do
  json.call(@post.category, :id, :name, :link)
end


# counts
json.call(@post, :total_views, :comments_count, :upvotes_count, :counted_watchtime)

# viewer specific info
json.available @post.available?(@current_user)

if @current_user
  json.can_comment @post.allow_comments
  json.can_takko   @post.can_takko?(@current_user)
  json.voted       Vote.find_for(@post, @current_user)
end
