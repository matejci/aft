# frozen_string_literal: true

class CampaignSubscriber
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :ip_address, type: String
  field :user_agent, type: String

  validates :email, presence: true, uniqueness: { scope: [:campaign_id] }

  belongs_to :campaign, dependent: :destroy
end
