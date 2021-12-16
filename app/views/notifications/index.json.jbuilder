# frozen_string_literal: true

json.array! @notifications do |notification|
  json.extract! notification, :id, :created_at, :action, :description, :image_url, :notifiable_url
  json.created_at_in_words time_ago_in_words(notification.created_at)

  json.actor do
    actor = notification.actor
    json.extract!  actor, :username, :profile_thumb_url, :profile_image_version, :verified
    json.following @current_user.follows? actor
  end
end
