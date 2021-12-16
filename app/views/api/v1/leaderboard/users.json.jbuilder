# frozen_string_literal: true

json.set! :users do
  json.array! @collection do |user|
    json.extract! user, :id, :email, :phone, :display_name, :first_name, :last_name, :username, :profile_thumb_url,
                  :followers_count, :comments_count, :takkos_received, :verified, :counted_watchtime
  end
end

