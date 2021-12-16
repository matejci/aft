json.extract! subscriber, :id, :firstName, :lastName, :email, :age, :link, :invite, :status, :created_at, :updated_at
json.url subscriber_url(subscriber, format: :json)
