json.upvotes_count @post.reload.upvotes_count
json.voted         Vote.find_for(@post, @current_user)
