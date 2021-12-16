json.array! @users do |user|
  json.cache! user do
    json.partial! 'users/tag', user: user
  end
end
