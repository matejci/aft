# frozen_string_literal: true

json.total_pages @collection[:total_pages]
json.comments_count @collection[:comments_count]

json.comments do
  json.array! @collection[:comments], partial: 'comments/comment', as: :comment
end
