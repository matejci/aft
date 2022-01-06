# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :confirm_user_logged_in, :set_base_date

  def index
    counted_views      = @current_user.views.counted.where(:date.lte => @base_date)
    counted_watch_time = @current_user.watch_times.counted.where(:date.lte => @base_date)
    finalized_payouts  = @current_user.payouts.finalized.where(:date.lte => @base_date)
    unpaid_payouts     = @current_user.payouts.unpaid.where(:date.lte => @base_date)

    @metric_all_time = {
      views: counted_views.count,
      watch_times: counted_watch_time.sum(:total).to_i,
      earnings: finalized_payouts.sum(:paying_amount_in_cents) / 100.0,
      balance: unpaid_payouts.sum(:paying_amount_in_cents) / 100.0,
      upvotes_count: @current_user.posts.active.sum(:upvotes_count)
    }

    [7, 30].each do |n|
      last_date = @base_date - (n - 1)

      metric_hash = {
        views: counted_views.where(:date.gte => last_date).count,
        watch_times: counted_watch_time.where(:date.gte => last_date).sum(:total).to_i,
        earnings: finalized_payouts.where(:date.gte => last_date).sum(:paying_amount_in_cents) / 100.0,
        balance: unpaid_payouts.where(:date.gte => last_date).sum(:paying_amount_in_cents) / 100.0,
        upvotes_count: @current_user.posts.active.where(:publish_date.gte => last_date).sum(:upvotes_count)
      }

      instance_variable_set("@metric_last_#{n}_days", metric_hash)
    end
  end

  def payouts
    # each page shows 14 days of payouts data
    last_date = @base_date - ((params[:page].to_i - 1) * 14)
    @dates = last_date.downto(last_date - 13)
    @payouts = @current_user.payouts.finalized
  end

  private

  def set_base_date
    # NOTE: offset validation period for payouts
    @base_date = Date.yesterday - PoolInterval::VALIDATION_PERIOD
  end
end
