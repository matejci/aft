
json.set! :usernames do
	json.array! @usernames do |username|
		json.extract! username, :id, :name, :type, :status

		json.set! :created_at, username.created_at.strftime("%b %e, %Y - %l:%M%P").to_s

		unless username.user_id.nil?
			json.set! :user, username.user.email
		else
			json.set! :user, nil
		end
	end
end

json.set! :usernamesTotal, @usernames.total_count
json.set! :usernamesTotalPages, @usernames.total_pages