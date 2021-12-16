# frozen_string_literal: true

module OneTimeJobs
  class FilterSogouExplorerJob < ApplicationJob
    queue_as :default

    def perform
      Rails.logger.info('Filtering Sougou Explorer started!')

      sogou_vt_ids = ViewTracking.in(
        session_id: Session.where(device_client_name: /sogou/i).pluck(:id)
      ).pluck(:id)

      ViewTracking.in(id: sogou_vt_ids).update_all(flagged: 'sogou_explorer')

      # clean affected views in validation period
      date_in_validation = Date.current - PoolInterval::VALIDATION_PERIOD
      affected_views = View.where(:date.gte => date_in_validation, :view_tracking_id.in => sogou_vt_ids)
      affected_views.update_all(counted: false)
      WatchTime.where(:date.gte => date_in_validation, :view_tracking_id.in => sogou_vt_ids).update_all(counted: false)

      # update total views for affected posts
      affected_views.group(
        _id: '$post_id',
        counted: { '$sum': { '$cond': ['$counted', 1, 0] } }
      ).aggregate.each do |post|
        Post.find(post['_id']).inc(total_views: -post['counted'])
      end

      # reload watch times for affected pool intervals
      PoolInterval.forecasted.where(:date.gte => date_in_validation, :date.lte => Date.current).each do |interval|
        interval.watch_time_loaded = false
        interval.load_watch_times
      end

      Rails.logger.info('Filtering Sougou Explorer completed!')
    end
  end
end
