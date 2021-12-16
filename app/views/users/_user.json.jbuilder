# frozen_string_literal: true

json.extract! user, :id, :email, :phone, :display_name, :first_name, :last_name, :username,
              :bio, :completed_signup, :profile_thumb_url, :profile_image_version,
              :background_image_url, :background_image_version, :verified,
              :creator_program_opted, :monetization_status_type

json.access_token @current_session.try(:token) || request.headers['HTTP-ACCESS-TOKEN'] if @current_session&.user == user || @current_user == user

# so iOS can load profile data
# jbuilder takes care of duplicate keys
json.partial! 'profiles/user', user: user

json.partial! 'users/valid_account', user: user

json.active_account user.active_account?
json.creator_program_active CreatorProgram.first&.active

json.paypal_email user.paypal_account.try(:paypal_email)
