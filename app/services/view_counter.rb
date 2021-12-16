# frozen_string_literal: true

class ViewCounter
  class << self
    def run!(interval = 10.minutes) # rubocop:disable Metrics/MethodLength
      View.where(
        counted: nil, :created_at.lte => (Time.current - interval)
      ).lookup(
        from: 'view_trackings',
        localField: 'view_tracking_id',
        foreignField: '_id',
        as: 'view_tracking'
      ).unwind(
        path: '$view_tracking'
      ).group(
        _id: '$view_tracking_id',
        flagged: { '$first': '$view_tracking.flagged' },
        current_counts: { '$first': '$view_tracking.current_counts' },
        view_id: { '$push': '$_id' },
        started_at: { '$push': '$started_at' },
        min_date: { '$min': '$date' },
        max_date: { '$max': '$date' }
      ).aggregate.each do |vt|
        view_tracking = ViewTracking.find(vt['_id'])
        current_counts = vt['current_counts']

        counted = []
        counted_timestamps = []

        not_counted = []
        not_counted_timestamps = []

        vt['started_at'].each_with_index do |started_at, idx|
          view_id = vt['view_id'][idx]
          count_eligibility = CountEligibilityCheckService.new(flagged: vt['flagged'], current_counts: current_counts, started_at: started_at).call

          if count_eligibility[:eligible]
            counted << view_id
            counted_timestamps << started_at
            current_counts = count_eligibility[:current_counts]
          else
            not_counted << view_id
            not_counted_timestamps << started_at
          end
        end

        View.in(id: counted).set(counted: true)
        View.in(id: not_counted).set(counted: false)

        if view_tracking.watch_time_eligible
          WatchTime.where(view_tracking: view_tracking).in(started_at: counted_timestamps).set(counted: true)
          WatchTime.where(view_tracking: view_tracking).in(started_at: not_counted_timestamps).set(counted: false)
        end

        view_tracking.set(current_counts: current_counts)

        post = view_tracking.post
        post.atomically do
          post.inc(total_views: counted.length)
          post.set(counts_updated_at: Time.current) # to expire counts view cache
          post_update = post.set(counted_watchtime: calculate_watchtime(post))
          post.user.set(counted_watchtime: post.user.counted_watchtime + post_update.counted_watchtime)
        end

        PoolInterval.where(:date.gte => vt['min_date'], :date.lte => vt['max_date']).update_all(watch_time_loaded: false)
      end
    end

    def calculate_watchtime(post)
      original_watchtime = post.watch_times.counted.sum(:total)
      boost_list_watchtime = 0
      post_boost_watchtime = 0

      conf = IosConfigService.new.call

      # boost if post.user is in boost_list
      if conf.boost_list.include?(post.user.id.to_s)
        boost_list_watchtime = original_watchtime
        boost_list_watchtime *= conf.boost_value
      end

      # boost if new post
      if conf.post_boost['expires_at'] > Time.current && conf.post_boost['post_ids'].include?(post.id.to_s)
        post_boost_watchtime = original_watchtime
        post_boost_watchtime *= conf.post_boost['boost_value']
        conf.post_boost['post_ids'].delete(post.id.to_s)
        conf.save
      end

      original_watchtime + boost_list_watchtime + post_boost_watchtime
    end
  end
end
