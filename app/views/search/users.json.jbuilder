# frozen_string_literal: true

json.total_pages @collection[:total_pages]

json.data do
  json.array! @collection[:data], partial: 'users', as: :user
end
