# frozen_string_literal: true

json.data do
  json.array!(@collection, :id, :username, :display_name, :email, :phone, :verified, :profile_thumb_url, :first_name, :last_name)
end
