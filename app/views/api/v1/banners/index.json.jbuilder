# frozen_string_literal: true

json.total_pages @collection.total_pages

json.data do
  json.array! @collection, :id, :image_url, :link, :order
end
