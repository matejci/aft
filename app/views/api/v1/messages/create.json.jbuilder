# frozen_string_literal: true

json.data do
  json.extract! @message, :id, :content, :link
end
