# frozen_string_literal: true

class CreatorProgram
  include Mongoid::Document
  include Mongoid::Timestamps

  field :active, type: Boolean, default: false
  field :threshold, type: Integer, default: 100
  field :participants, type: Array, default: []
end
