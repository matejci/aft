json.array! @followers do |user|
  json.partial!  'users/tag', user: user
  json.following @current_user.follows?(user)
end
