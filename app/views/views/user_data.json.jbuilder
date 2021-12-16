json.date @date.strftime('%m/%d/%Y')
json.(@user, :username, :full_name)

json.cache! @views do
  @posts = @views.lookup(from: 'posts', localField: 'post_id', foreignField: '_id', as: 'post')
                 .unwind('$post')
                 .group(
                   _id:               '$post_id',
                   parent_id:         {'$first': '$post.parent_id'},
                   publish_date:      {'$first': '$post.publish_date'},
                   title:             {'$first': '$post.title'},
                   video_length:      {'$first': '$post.video_length'},
                   total_views:       {'$sum': 1},
                   counted_views:     {'$sum': {'$cond': ['$counted', 1, 0]}},
                   viewer_ids:        {'$addToSet': '$viewed_by_id'},
                   view_tracking_ids: {'$addToSet': '$view_tracking_id'}
                  ).aggregate

  json.posts @posts do |post|
    json.extract!              post, :title, :video_length, :total_views, :counted_views
    json.id                    post['_id']
    json.post                  post['parent_id'].present? ? 'takko' : 'post'
    json.date_published        post['publish_date'].strftime('%m/%d/%Y')
    json.total_unique_users    post['viewer_ids'].length
    json.total_unique_sessions post['view_tracking_ids'].length

    watch_time = @watch_times.where(post_id: post['_id'])
    json.total_watch_time      watch_time.sum(:total)
    json.counted_watch_time    watch_time.counted.sum(:total)
    json.total_unique_watchers watch_time.distinct(:watched_by_id).count
  end
end
