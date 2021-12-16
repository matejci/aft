
json.set! :invitations do
	json.array! @invitations do |invitation|
		json.extract! invitation, :_id, :claimed_date, :ip_address, :user_agent, :invite_code, :claimed, :status, :attempts, :number_of_attempts, :user_id, :subscriber_id, :email_sent, :email_used, :invited_by, :invited_type, :device_name, :device_type, :device_client_name, :device_client_full_version, :device_os, :device_os_full_version, :device_client_known 

		json.set! :created_at, invitation.created_at.strftime("%b %e, %Y - %l:%M%P").to_s
		json.set! :updated_at, invitation.updated_at.strftime("%b %e, %Y - %l:%M%P").to_s

		# unless invitation.parent_id.nil?
		# 	referred_invitation = Invitation.find(invitation.parent_id)
		# 	json.set! :referred_by, referred_invitation.email
		# else
		# 	json.set! :referred_by, nil
		# end
	end
end

json.set! :invitationsTotal, @invitations.total_count
json.set! :invitationsTotalPages, @invitations.total_pages