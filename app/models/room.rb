# frozen_string_literal: true

class Room
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :members, class_name: 'User'
  has_many :messages, dependent: :destroy

  field :name, type: String
  field :link, type: String
  field :created_by_id, type: String
  field :is_public, type: Boolean, default: false

  validates :created_by_id, presence: true
  validates :name, uniqueness: true

  before_create :generate_name, unless: Proc.new { name.present? }

  private

  def generate_name
    self.name = loop do
      room_name = "ChatRoom_#{SecureRandom.hex}"
      break room_name unless Room.where(name: room_name).exists?
    end
  end
end
