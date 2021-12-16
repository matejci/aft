# frozen_string_literal: true

class Contest
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :winner, class_name: 'User', dependent: :nullify, optional: true
  belongs_to :post, dependent: :nullify

  field :name, type: String
  field :active, type: Boolean, default: true
  field :archived_at, type: DateTime

  validates :active, uniqueness: true, if: :active # allow only 1 active contest at the time

  before_save :post_valid?

  scope :active, -> { where(active: true) }

  def post_valid?
    return true if post.active? && post.original? && post.completed? && post.status

    errors.add(:base, 'Post is invalid')
    throw(:abort)
  end
end
