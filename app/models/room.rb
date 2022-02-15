# frozen_string_literal: true

class Room
  include Mongoid::Document
  include Mongoid::Timestamps

  has_and_belongs_to_many :members, class_name: 'User'
  has_many :messages, dependent: :destroy
  belongs_to :created_by, class_name: 'User', dependent: :nullify

  field :name, type: String
  field :created_by_id, type: String
  field :is_public, type: Boolean, default: false
  field :last_read_messages, type: Hash, default: {}

  validates :created_by_id, presence: true
  validates :name, presence: true

  before_validation :generate_name, unless: Proc.new { name.present? }, on: :create

  private

  def generate_name
    self.name = members.map(&:username).join(' ')
  end
end
