# frozen_string_literal: true

class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  validates :name, presence: true

  has_many :subscribers, class_name: 'CampaignSubscriber', dependent: :destroy
end
