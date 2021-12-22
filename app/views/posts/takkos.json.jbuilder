# frozen_string_literal: true

json.total_pages @collection[:total_pages]
json.takkos_count @collection[:takkos_count]

post = @collection[:post]

json.data do
  json.id post.feed_item_id
  json.parent_id post.parent_id || post.id
  json.selected_id post.id
  json.default_takko_order post.takko_order

  json.items @collection[:data] do |takko|
    json.partial! 'posts/takko', takko: takko
  end
end
