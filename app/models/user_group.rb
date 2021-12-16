# frozen_string_literal: true

class UserGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  has_and_belongs_to_many :users

  field :name, type: String

  validates :name, presence: true, uniqueness: { scope: :user }
end
