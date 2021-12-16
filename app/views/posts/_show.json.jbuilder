# frozen_string_literal: true

json.cache! post do
  # post info
  json.extract! post, :id, :link, :title, :publish_date, :description, :media_file_url, :video_length, :deleted,
                :video_transcoded, :media_thumbnail_dimensions, :animated_cover_url, :media_type

  json.published time_ago_in_words(post.publish_date)

  # to avoid ActionView::Template::Error (can't dump anonymous class)
  json.media_thumbnail post.media_thumbnail.as_json
  json.master_playlist "#{post.media_file_url}_playlist.m3u8"
end

json.cache! post.user do
  # owner info
  json.user post.user, partial: 'users/tag', as: :user
end

json.cache! post.category do
  # category info
  json.category do
    json.call(post.category, :id, :name, :link)
  end
end

json.cache! post.counts_cache_key do
  # counts
  json.call(post, :total_views, :comments_count, :upvotes_count, :counted_watchtime)
end

json.cache! [post, post.counts_cache_key, @viewer] do
  # viewer specific info
  json.available post.available?(@viewer)

  if @viewer
    json.can_comment post.allow_comments
    json.can_takko   post.can_takko?(@viewer)
    json.voted       Vote.find_for(post, @viewer)
  end
end
