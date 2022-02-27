# frozen_string_literal: true

class Room
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :members, class_name: 'User', inverse_of: :rooms
  has_and_belongs_to_many :ex_members, class_name: 'User', inverse_of: :ex_rooms
  has_many :messages, dependent: :destroy
  belongs_to :created_by, class_name: 'User', dependent: :nullify

  field :name, type: String
  field :generated_name, type: String
  field :created_by_id, type: String
  field :last_read_messages, type: Hash, default: {}
  field :room_thumb, type: String
  field :members_count, type: Integer, default: 0

  validates :created_by_id, presence: true

  attr_accessor :last_message
end
