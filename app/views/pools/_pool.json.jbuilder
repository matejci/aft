json.extract! pool, :created_at, :id, :name, :amount, :start_date, :end_date,
                    :daily_amount, :estimated_amount, :fixed_amount,
                    :paid_amount, :processed_amount, :remaining_amount

json.dates "#{pool.start_date.strftime("%m/%d/%Y")} - #{pool.end_date.strftime("%m/%d/%Y")}"
json.url pool_url(pool, format: :json)

json.intervals pool.intervals.asc(:date), :id, :date, :fixed, :amount, :status
