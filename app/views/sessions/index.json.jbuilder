
json.set! :sessions do
	json.array! @sessions do |session|
		json.extract! session, :_id, :ip_address, :access_token, :token, :user_agent, :exp_date, :status, :live, :device_name, :device_type, :device_client_name, :device_client_full_version, :device_os, :device_os_full_version, :device_client_known

		json.set! :created_at, session.created_at.strftime("%b %e, %Y - %l:%M%P").to_s
		unless session.last_login.nil?
			json.set! :last_login, session.last_login.strftime("%b %e, %Y - %l:%M%P").to_s
		else
			json.set! :last_login, nil
		end
		unless session.last_activity.nil?
			json.set! :last_activity, session.last_activity.strftime("%b %e, %Y - %l:%M%P").to_s
		else
			json.set! :last_activity, nil
		end
		# unless session.email_delivery_date.nil?
		# 	json.set! :email_delivery_date, session.email_delivery_date.strftime("%b %e, %Y - %l:%M%P").to_s
		# else
		# 	json.set! :email_delivery_date, nil
		# end

		unless session.app_id.nil?
			app = App.find(session.app_id)
			json.set! :app, app.name
			json.set! :app_id, app._id.to_s
		else
			json.set! :app, nil
		end

		unless session.user_id.nil?
			user = User.find(session.user_id)
			json.set! :user, user.email
		else
			json.set! :user, nil
		end
	end
end

json.set! :sessionsTotal, @sessions.total_count
json.set! :sessionsTotalPages, @sessions.total_pages