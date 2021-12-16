# frozen_string_literal: true

json.pool do
  json.extract! @pool_interval.pool, :id, :name, :amount
end

json.extract! @pool_interval, :id, :created_at, :date, :validate_by, :fixed, :amount, :total_watch_time, :watch_time_rate, :status

json.users MonetizableWatchTimeQuery.users(@pool_interval.watch_times) do |user|
  json.extract! user, :_id, :total_watch_time, :username, :full_name
end

json.payouts @pool_interval.payouts, :id, :date, :status, :user_id, :user_username, :user_full_name, :amount, :paying_amount, :remaining_amount,
             :watch_time, :percent, :counted_views, :total_views

json.view_logger_jobs_count Sidekiq::Queue.new('view_logger_jobs').size
json.view_counter_jobs_count Sidekiq::Queue.new('view_counter_jobs').size

json.not_counted_watch_times_count @pool_interval.watch_times.where(counted: nil).count
