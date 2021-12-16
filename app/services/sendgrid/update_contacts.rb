# frozen_string_literal: true

require 'uri'
require 'net/http'

module Sendgrid
  class UpdateContacts
    def initialize(user_ids)
      @user_ids = user_ids
    end

    attr_reader :user_ids

    def call
      return unless (sendgrid_list = ENV['SENDGRID_CONTACTS_LIST'])

      url = URI('https://api.sendgrid.com/v3/marketing/contacts')

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Put.new(url)
      request['authorization'] = "Bearer #{ENV['SENDGRID_API_KEY']}"
      request['content-type'] = 'application/json'
      request.body = {
        list_ids: [sendgrid_list],
        contacts: contacts_array
      }.to_json

      response = http.request(request)
      resp = response.read_body
      Rails.logger.info(resp)
    end

    private

    # Maps our users to Sendgrid contact
    # Sendgrid API enforces usage of custom field IDs as keys so here is the mapping:
    # e5_T => account_status
    # e6_N => posts_count
    # e3_D => removal_requested_at
    # e7_T => creator_program_opted
    def contacts_array
      users = User.where(:_id.in => user_ids).to_a
      users.map do |user|
        custom_fields = { e5_T: user.acct_status.to_s, e6_N: user.posts_count, e7_T: user.creator_program_opted.present?.to_s }
        custom_fields[:e3_D] = user.removal_requested_at.iso8601 if user.removal_requested_at.present?

        {
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          custom_fields: custom_fields
        }
      end
    end
  end
end
