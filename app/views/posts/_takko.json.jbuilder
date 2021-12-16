# frozen_string_literal: true

json.cache! takko do
  json.extract! takko, :id, :link, :title, :publish_date, :description, :media_file_url, :video_length, :video_transcoded, :media_thumbnail_dimensions, :animated_cover_url, :media_type
  json.published time_ago_in_words(takko.publish_date)
  json.media_thumbnail takko.media_thumbnail.as_json
  json.master_playlist "#{takko.media_file_url}_playlist.m3u8"
end

json.cache! takko.user do
  json.user takko.user, partial: 'users/tag', as: :user
end

json.cache! takko.category do
  json.category do
    json.call(takko.category, :id, :name, :link)
  end
end

json.cache! takko.counts_cache_key do
  json.call(takko, :total_views, :comments_count, :upvotes_count, :counted_watchtime)
end

json.cache! [takko, takko.counts_cache_key, @current_user] do
  if @current_user
    json.can_comment takko.allow_comments
    json.can_takko   takko.can_takko?(@current_user)
    json.voted       Vote.find_for(takko, @current_user)
  end
end
