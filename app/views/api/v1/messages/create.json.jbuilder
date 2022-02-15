# frozen_string_literal: true

json.data do
  json.extract! @message, :id, :content, :message_type
  json.payload_url @message.payload.url
end
