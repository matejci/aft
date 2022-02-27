# frozen_string_literal: true

json.data do
  json.extract! @room, :id, :name, :generated_name, :created_by_id, :members_count, :room_thumb
end
