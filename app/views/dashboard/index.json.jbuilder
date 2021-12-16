json.filter_metrics do
  json.all_time do
  	json.views 					      @metric_all_time[:views]
  	json.watch_times 			    @metric_all_time[:watch_times]
  	json.earnings 				    @metric_all_time[:earnings]
  	json.earnings_in_currency number_to_currency(@metric_all_time[:earnings])
    json.balance 				      @metric_all_time[:balance]
  	json.balance_in_currency 	number_to_currency(@metric_all_time[:balance])
  end

  json.last_7_days do
  	json.views 					      @metric_last_7_days[:views]
  	json.watch_times 			    @metric_last_7_days[:watch_times]
  	json.earnings 				    @metric_last_7_days[:earnings]
  	json.earnings_in_currency number_to_currency(@metric_last_7_days[:earnings])
    json.balance 			      	@metric_last_7_days[:balance]
  	json.balance_in_currency 	number_to_currency(@metric_last_7_days[:balance])
  end

  json.last_30_days do
  	json.views 					      @metric_last_30_days[:views]
  	json.watch_times 			    @metric_last_30_days[:watch_times]
  	json.earnings 				    @metric_last_30_days[:earnings]
  	json.earnings_in_currency number_to_currency(@metric_last_30_days[:earnings])
    json.balance 				      @metric_last_30_days[:balance]
  	json.balance_in_currency 	number_to_currency(@metric_last_30_days[:balance])
  end
end

# NOTE: leaving the key 'connected_account' so ios parsing does not break
json.connected_account do
  json.user do
    json.extract! @current_user, :monetization_status, :monetization_status_type
    json.paypal_email @current_user.paypal_account.email
  end
end

json.extract! @current_user, :monetization_status, :monetization_status_type
json.paypal_email @current_user.paypal_account.email
