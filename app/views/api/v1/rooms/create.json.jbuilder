# frozen_string_literal: true

json.data do
  json.extract! @room, :id, :name, :created_by_id, :is_public
end
