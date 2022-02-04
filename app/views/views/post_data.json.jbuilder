json.(@user, :username, :full_name)
json.(@post, :type)
json.date_published @post.publish_date.strftime('%m/%d/%Y')
json.viewed_date    @date.strftime('%m/%d/%Y')

json.cache! @views do
  @viewers = @views.lookup(from: 'users', localField: 'viewed_by_id', foreignField: '_id', as: 'viewer')
                   .unwind({ path: '$viewer', preserveNullAndEmptyArrays: true })
                   .group(
                     _id:               '$viewed_by_id',
                     username:          {'$first': '$viewer.username'},
                     full_name:         {'$first': { '$concat': ['$viewer.first_name', ' ', '$viewer.last_name'] } },
                     total_views:       {'$sum': 1},
                     counted_views:     {'$sum': {'$cond': ['$counted', 1, 0]}},
                     view_tracking_ids: {'$addToSet': '$view_tracking_id'}
                   ).aggregate

  json.viewers @viewers do |viewer|
    json.extract!           viewer, :username, :full_name, :total_views, :counted_views
    json.id                 viewer['_id']
    json.view_trackings     viewer['view_tracking_ids'].length

    watch_time = @watch_times.where(watched_by_id: viewer['_id'])
    json.total_watch_time   watch_time.sum(:total)
    json.counted_watch_time watch_time.counted.sum(:total)
  end
end
