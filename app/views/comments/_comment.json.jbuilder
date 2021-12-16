# frozen_string_literal: true

json.extract! comment, :id, :text, :rich_text, :status, :phantom, :phantom_by, :link, :post_id, :created_at, :updated_at
json.url post_comment_url(comment.post, comment, format: :json)
json.commented time_ago_in_words(comment.created_at)
json.user comment.user, partial: 'users/tag', as: :user

json.partial! 'api/v1/votes/upvote', locals: { model_object: comment } if @current_user
