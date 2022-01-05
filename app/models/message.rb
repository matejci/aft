# frozen_string_literal: true

class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :room
  belongs_to :sender, class_name: 'User'

  field :content, type: String
  field :link, type: String

  mount_uploader :attachment, MsgAttachmentUploader

  validates :content, presence: true
end
