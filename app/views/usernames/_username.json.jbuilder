json.extract! username, :id, :name, :type, :status, :user_id, :created_at, :updated_at
json.url username_url(username, format: :json)
