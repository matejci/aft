# frozen_string_literal: true

class Session
  include Mongoid::Document
  include Mongoid::Timestamps

  field :exp_date, type: DateTime
  field :last_login, type: DateTime
  field :last_activity, type: DateTime

  field :access_token, type: String
  field :token, type: String
  field :user_agent, type: String
  field :ip_address, type: String

  field :status, type: Boolean, default: true # session shutoff
  field :live, type: Boolean, default: true # user sign-in/out
  field :admin_login, type: Boolean, default: false

  # user agent device detector
  field :device_name, type: String
  field :device_type, type: String
  field :device_client_name, type: String
  field :device_client_full_version, type: String
  field :device_os, type: String
  field :device_os_full_version, type: String
  field :device_client_known, type: Boolean
  field :device_token, type: String

  # one signal
  field :player_id, type: String

  belongs_to :user, optional: true
  belongs_to :app, optional: true
  belongs_to :currently_viewing, class_name: 'ViewTracking', optional: true
  has_many :view_trackings, dependent: :nullify

  scope :active, -> { where(status: true) }
  scope :guest,  -> { where(user_id: nil) }
  scope :live,   -> { active.where(live: true) }
  scope :ios,    -> { where(device_os: 'iOS') }

  # TO-DO: in sessions model assign access_token, attributes: user_agent, exp_date, requests (int)?
end
