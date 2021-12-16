# frozen_string_literal: true

require 'rails_helper'
require 'rspec_api_documentation'
require 'rspec_api_documentation/dsl'
require 'support/authenticated_request'
require 'support/configuration'

RspecApiDocumentation.configure do |config|
  config.format = [:api_blueprint]
  config.request_headers_to_include = %w[APP-ID HTTP-X-APP-TOKEN HTTP-ACCESS-TOKEN X-API-VERSION]
  config.response_headers_to_include = ['Content-Type']
  config.api_name = 'takko API Documentation'
end

def parsed_response
  JSON.parse(response_body)
end

def include_user_attributes
  with_options scope: :user do
    parameter :first_name, 'first name'
    parameter :last_name, 'last name'
    parameter :bio
    parameter :birthdate, 'birthdate (YYYY-MM-DD)'
    parameter :email
    parameter :new_email, 'email to be updated to'
    parameter :email_code, '4-digits verification code send to email'
    parameter :phone
    parameter :new_phone, 'phone to be updated to'
    parameter :phone_code, '4-digits verification code send to phone'
    parameter :username
    parameter :display_name, 'display name'
    parameter :website
    parameter :password
    parameter :new_password, 'new password'
    parameter :new_password_confirmation, 'new password confirmation'
    parameter :invite, 'invite code'
    parameter :profile_image, 'profile image'
    parameter :background_image, 'background image'
    parameter :tos_acceptance, 'agreeing to terms of service'
  end
end
