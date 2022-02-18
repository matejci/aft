# frozen_string_literal: true

json.data do
  json.array! @messages, :id, :content, :sender_id, :message_type, :created_at, :updated_at, :payload
end
