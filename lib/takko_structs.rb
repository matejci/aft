# frozen_string_literal: true

module TakkoStructs
  CustomPost = Struct.new('CustomPost', :post, :user, :category, :takkos, :carousel_muted)
  CustomTakko = Struct.new('CustomTakko', :post, :user, :category, :can_takko, :voted, :takkos_received, :bookmarked)

  HashtagPost = Struct.new('HashtagPost', :id, :description, :media_thumbnail_dimensions, :media_thumbnail, :user, :views_count)
  HashtagUser = Struct.new('HashtagUser', :id, :email, :phone, :display_name, :username, :profile_image_thumb_url)

  CustomUser = Struct.new('CustomUser', :id, :email, :phone, :display_name, :first_name, :last_name, :username, :profile_thumb_url,
                          :followers_count, :counted_watchtime, :comments_count, :takkos_received, :verified)
end
