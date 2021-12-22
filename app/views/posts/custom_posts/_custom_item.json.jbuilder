# frozen_string_literal: true

json.item do
  json.type 'post'
  json.id custom_post.post.feed_item_id

  json.parent_id custom_post.post.parent_id || custom_post.post.id
  json.selected_id custom_post.post.id
  json.carousel_muted custom_post.carousel_muted

  json.items custom_post.takkos.each do |takko|
    json.extract! takko.post, :id, :link, :title, :publish_date, :description, :media_file_url, :video_length, :video_transcoded,
                  :media_thumbnail_dimensions, :animated_cover_url, :media_type, :shares_count

    json.published time_ago_in_words(takko.post.publish_date)
    json.media_thumbnail takko.post.media_thumbnail.as_json
    json.master_playlist "#{takko.post.media_file_url}_playlist.m3u8"

    json.user takko.user, partial: 'users/tag', as: :user

    json.category do
      json.call(takko.category, :id, :name, :link)
    end

    json.call(takko.post, :total_views, :comments_count, :upvotes_count, :counted_watchtime)

    json.takkos_received takko.takkos_received

    if @current_user
      json.can_comment takko.post.allow_comments
      json.can_takko takko.can_takko
      json.voted takko.voted
      json.bookmarked takko.bookmarked
    end
  end
end
