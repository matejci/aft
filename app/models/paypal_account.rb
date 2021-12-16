# frozen_string_literal: true

class PaypalAccount
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable

  track_history on: [:email], modifier_field: nil

  belongs_to :user

  field :email, type: String
  field :country, type: String

  validates :email, email_format: true, presence: true
end
