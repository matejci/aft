# frozen_string_literal: true

class CampaignsController < ApplicationController
  layout 'campaign'

  def recipetube; end

  def cryptotube; end

  def kpopfam; end

  def subscribe
    campaign = Campaign.find_by(name: params[:campaign_name])

    if campaign.blank?
      @errors = ['Wrong campaign']
    else
      subscriber = campaign.subscribers.create(email: params[:email], ip_address: request.remote_ip, user_agent: request.headers['user-agent'])

      @errors = subscriber.errors.full_messages if subscriber.errors.any?
    end
  end
end
