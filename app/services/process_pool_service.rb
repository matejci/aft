# frozen_string_literal: true

# TODO, refactor this
class ProcessPoolService
  def initialize; end

  def call
    process_pool
  end

  private

  def process_pool
    PoolInterval.forecasted.where(processing_date: Date.current).each do |interval|
      # NOTE: move this the date following interval date or creation date after fixing counter bug
      interval.load_watch_times unless interval.watch_time_loaded
      interval.update(status: :processed)
    end

    # process payouts that are due to be processed today
    PoolInterval.process_payouts!(Date.current)
  end
end
