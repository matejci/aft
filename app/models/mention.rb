# frozen_string_literal: true

class Mention
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  belongs_to :mentionable, polymorphic: true
  belongs_to :user, optional: true, inverse_of: :mentions
  belongs_to :mentioned_by, class_name: 'User', inverse_of: :my_mentions

  field :body,     type: String
  field :read,     type: Boolean, default: false
  field :seen,     type: Boolean, default: false
  field :status,   type: Boolean, default: true
  field :template, type: String

  validates :user, presence: true, on: :create
  validates :mentionable_type, presence: true, inclusion: { in: %w[Post Comment] }
  validate  :allowed_to_mention

  private

  def allowed_to_mention
    errors.add(:base, 'Not allowed to mention') if Block.exists_for?(user, mentioned_by)
  end
end
