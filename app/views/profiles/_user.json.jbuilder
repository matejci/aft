# frozen_string_literal: true

json.cache! user do
  json.partial! 'users/tag', user: user
  json.extract! user, :bio, :website, :background_image_url, :background_image_version, :followers_count, :followees_count, :posts_count, :takkos_count
end

if @viewer # viewer specific info
  json.cache! [user, @viewer] do
    json.owner     user == @viewer
    json.following @viewer&.follows?(user)
    json.blocked   @viewer&.blocked?(user)
  end
end

if @creator_program
  json.creator_program_active @creator_program.active
  json.creator_program_opted user.creator_program_opted
end

json.badges @user.configuration.badges if @user
