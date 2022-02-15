# frozen_string_literal: true

json.data do
  json.array! @rooms, :id, :name, :created_by_id, :created_at, :updated_at
end
