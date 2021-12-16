json.extract! mention, :_id, :mentioned_by_id, :user_id, :template, :body, :read, :seen, :type, :status, :post_id, :comment_id, :created_at, :updated_at
json.url mention_url(mention, format: :json)
