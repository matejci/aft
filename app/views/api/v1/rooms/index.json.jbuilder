# frozen_string_literal: true

json.data do
  json.array! @rooms, :id, :name, :created_by_id, :is_public, :created_at
end
