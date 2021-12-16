# frozen_string_literal: true

class UserConfiguration
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  field :ads, type: Hash, default: {}
  field :app_tracking_transparency_recorded_at, type: DateTime
  field :support, type: Hash, default: {}
  field :watched_items, type: Array, default: []
  field :push_notifications_settings, type: Hash, default: DEFAULT_PUSH_NOTIFICATIONS_SETTINGS
  field :carousel_notifications_blacklist, type: Array, default: []
  field :bookmarks, type: Array, default: []
  field :badges, type: Array, default: []
  field :video_files, type: Hash, default: {}

  enum :app_tracking_transparency, %i[authorized denied undetermined restricted]

  belongs_to :user
end
