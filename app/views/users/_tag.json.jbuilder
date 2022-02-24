# frozen_string_literal: true

json.(user, :id, :username, :display_name, :profile_thumb_url, :verified)
json.following @current_user.followees_ids.include?(user.id.to_s) if @current_user
