# frozen_string_literal: true

json.data do
  json.array! @collection, :id, :name, :generated_name, :created_by_id, :created_at, :updated_at, :last_read_messages, :members_count, :room_thumb, :last_message
end
