# frozen_string_literal: true

class Banner
  include Mongoid::Document
  include Mongoid::Timestamps

  field :order, type: Integer, default: 1
  field :link, type: String

  mount_uploader :image, BannerImageUploader

  validates :image, presence: true
  validates :order, numericality: { only_integer: true }
end
