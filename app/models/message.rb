# frozen_string_literal: true

class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  belongs_to :room
  belongs_to :sender, class_name: 'User'

  field :content, type: String
  enum :message_type, %i[text post contact]

  validates :content, :message_type, presence: true

  mount_uploader :payload, MsgAttachmentUploader

  validates :content, presence: true
end
