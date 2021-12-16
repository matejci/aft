# frozen_string_literal: true

module DeviceDetectable
  extend ActiveSupport::Concern

  included do
    field :device_name, type: String
    field :device_type, type: String
    field :device_client_name, type: String
    field :device_client_full_version, type: String
    field :device_os, type: String
    field :device_os_full_version, type: String
    # field :device_client_known, type: Boolean
  end

  def detect_device
    return if user_agent.blank?

    client = DeviceDetector.new(user_agent)
    self['device_name']                = client.device_name
    self['device_type']                = client.device_type
    self['device_client_name']         = client.name
    self['device_client_full_version'] = client.full_version
    self['device_os']                  = client.os_name
    self['device_os_full_version']     = client.os_full_version
    self['device_client_known']        = client.known?
  end
end
