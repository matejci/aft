json.array! @posts do |post|
  json.cache! post.max_cache_key do
    json.partial! 'posts/preview', post: post
  end
end
