# frozen_string_literal: true

json.item do
  json.type 'post'
  json.id custom_post.feed_item.id # TODO: not sure why FeedItem.id is used like post.id, probably should be removed, but leaving it now since it needs to mimic feed response

  json.parent_id custom_post.post.parent_id || custom_post.post.id
  json.selected_id custom_post.post.id

  json.items [custom_post.post] + custom_post.takkos.map(&:post) do |takko|
    json.partial! 'posts/tutorial/tutorial_post_show', takko: takko
  end
end
