json.viewed_date @date
json.(@post, :title, :type)
json.(@viewer, :username, :full_name) if @viewer

json.cache! @views do
  json.views @views.asc(:started_at) do |v|
    json.(v, :id, :counted, :view_tracking_id)

    json.start_time v.started_at.in_time_zone('Pacific Time (US & Canada)').strftime('%H:%M:%S.%L')
    json.end_time   v.ended_at.in_time_zone('Pacific Time (US & Canada)').strftime('%H:%M:%S.%L')

    wt = @watch_times.find_by(started_at: v.started_at)
    json.watch_time         wt&.total
    json.watch_time_counted wt&.counted
  end

  json.view_trackings @view_trackings do |vt|
    events = vt.event_timestamps.filter do |e|
      # NOTE: utc values stored in event_timestamps do not automatically get converted to pst..
      # unlike other timestamp values :(
      e.values.first.in_time_zone('Pacific Time (US & Canada)').to_date == @date
    end

    next if events.empty?

    json.(vt, :id)
    json.(vt.session, :user_agent, :ip_address)

    json.paused_events events.count{ |e| e.keys.first == 'paused' }
    json.events events do |e|
      json.action    e.keys.first
      json.timestamp e.values.first.in_time_zone('Pacific Time (US & Canada)').strftime('%H:%M:%S.%L')
    end
  end
end
