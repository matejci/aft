# frozen_string_literal: true

json.extract! category, :id, :name, :link, :status, :created_at, :updated_at, :icon, :filter_active_icon, :filter_inactive_icon
json.url category_url(category, format: :json)
