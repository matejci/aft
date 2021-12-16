class MonetizableWatchTimeQuery
  class << self
    def dated(date)
      watch_times(WatchTime.counted.dated(date)).project(_id: 1, total: 1, user_id: 1).aggregate
    end

    def for(date)
      watch_times(WatchTime.counted.dated(date)).group(
        _id:            '$date',
        total:          { '$sum': '$total' },
        user_ids:       { '$addToSet': '$user_id' },
        watch_time_ids: { '$push': '$_id' }
      ).aggregate.first
    end

    def users(criteria)
      watch_times(criteria)
        .group(
          _id: '$user_id',
          total_watch_time: { '$sum': '$total' },
          username:  { '$first': '$user.username' },
          full_name: { '$first': { '$concat': ['$user.first_name', ' ', '$user.last_name'] } }
        )
        .desc(:total_watch_time)
        .aggregate
    end

    private

    def watch_times(criteria)
      criteria
        .lookup(from: 'users', localField: 'user_id', foreignField: '_id', as: 'user')
        .unwind('$user')
        .match('user.monetization_status': true)
    end
  end
end
