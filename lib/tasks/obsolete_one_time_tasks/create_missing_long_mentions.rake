# frozen_string_literal: true

namespace :mentions do
  desc 'Create missing mentions for long usernames'
  task create_missing_long_mentions: :environment do
    User.valid.where(username: /\A.{21,}\z/).each do |user|
      mention = /@#{user.username}/i

      Comment.active.where(text: mention).each do |comment|
        next if comment.mentions.where(user: user).exists?

        comment.mentions.create!(user: user, mentioned_by: comment.user, body: comment.text)
      end

      Post.active.where(title: mention).each do |post|
        next if post.mentions.where(user: user).exists?

        post.mentions.create!(user: user, mentioned_by: post.user, body: post.title)
      end

      Post.active.where(description: mention).each do |post|
        next if post.mentions.where(user: user).exists?

        post.mentions.create!(user: user, mentioned_by: post.user, body: post.description)
      end
    end
  end
end
