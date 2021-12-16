# frozen_string_literal: true

json.extract! user_group, :id, :name

json.users user_group.users do |user|
  json.partial! 'users/tag', user: user
end
