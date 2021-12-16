# frozen_string_literal: true

module TakkoStructs
  CustomPost = Struct.new('CustomPost', :post, :feed_item, :user, :category, :takkos, :carousel_muted)
  CustomTakko = Struct.new('CustomTakko', :post, :user, :category, :can_takko, :voted, :takkos_received, :bookmarked)

  HashtagPost = Struct.new('HashtagPost', :id, :title, :description, :media_thumbnail_dimensions, :media_thumbnail, :user, :link_title, :views_count)
  HashtagUser = Struct.new('HashtagUser', :id, :email, :phone, :display_name, :username, :profile_image_thumb_url)

  CustomUser = Struct.new('CustomUser', :id, :email, :phone, :display_name, :first_name, :last_name, :username, :profile_thumb_url,
                          :followers_count, :counted_watchtime, :comments_count, :takkos_received, :verified)

  # leaderboard-posts
  # TODO, refactor so that only 1 struct is used on leaderboard-users and leaderboard-posts (maybe on another places also)
  LBPost = Struct.new('LBPost', :id, :title, :description, :media_thumbnail_dimensions, :media_thumbnail, :user, :link_title, :views_count,
                      :comments_count, :upvotes_count, :takkos_received, :animated_cover, :counted_watchtime)
  LBUser = Struct.new('LBUser', :id, :email, :phone, :display_name, :username, :verified)
end
