json.array! @followees do |user|
  json.partial!  'users/tag', user: user
  # true if viewing own profile, check follow if otherwise
  json.following @current_user == @user || @current_user.follows?(user)
end
