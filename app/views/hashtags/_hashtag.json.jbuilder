json.extract! hashtag, :_id, :name, :link, :status, :takeover, :created_by, :category_id, :created_at, :updated_at
json.url hashtag_url(hashtag, format: :json)
