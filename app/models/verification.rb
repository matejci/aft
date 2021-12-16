# frozen_string_literal: true

class Verification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :code, type: String
  field :expires_at, type: DateTime
  field :attempts, type: Array, default: []
  field :verifying_new, type: Boolean

  before_create :set_verifying_new
end
