json.array! @dates do |date|
  amount = @payouts.where(date: date).sum(:paying_amount_in_cents) / 100.0
  json.date                 date
  json.earnings             amount
  json.earnings_in_currency number_to_currency(amount)
end
