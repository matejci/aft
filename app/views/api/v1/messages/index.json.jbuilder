# frozen_string_literal: true

json.data do
  json.array! @messages, :id, :content, :created_at, :link, :room_id, :sender_id
end
