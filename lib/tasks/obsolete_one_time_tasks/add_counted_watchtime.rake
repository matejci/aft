# frozen_string_literal: true

namespace :posts do
  desc 'Add counted watchtime'
  task add_counted_watchtime: :environment do
    Post.update_all(counted_watchtime: 0)

    Post.includes(:watch_times).in(id: WatchTime.counted.distinct(:post_id)).desc(:updated_at).no_timeout.each do |post|
      total = post.watch_times.select { |wt| wt.counted == true }.sum(&:total)
      post.set(counted_watchtime: total)
    end

    User.includes(:posts).all.no_timeout.each do |user|
      user.set(counted_watchtime: user.posts.sum(&:counted_watchtime))
    end

    Rails.cache.redis.flushdb
  end
end
