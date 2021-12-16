json.extract! invitation, :id, :claimed_date, :ip_address, :user_agent, :invite_code, :claimed, :status, :attempts, :user_id, :subscriber_id, :created_at, :updated_at
json.url invitation_url(invitation, format: :json)
