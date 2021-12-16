# frozen_string_literal: true

class Report
  include Mongoid::Document
  include Mongoid::Timestamps
  include DeviceDetectable
  include Mongoid::History::Trackable

  track_history on: %i[notes status reporters], track_create: true

  belongs_to :reportable,  polymorphic: true
  belongs_to :reported_by, class_name: 'User'

  field :ip_address, type: String
  field :user_agent, type: String
  field :reporters, type: Array, default: []
  field :reason, type: String
  field :notes, type: String
  field :status, type: Boolean, default: true
  field :device_client_known, type: Boolean

  validates :reportable, uniqueness: { scope: :reported_by, message: 'already reported' },
                         if: -> { reported_by.present? }
  validate :cannot_report_self

  # TODO, change this, so that not the whole 'request' object is passed
  def request=(request)
    self.ip_address = request.remote_ip
    self.user_agent = request.user_agent
    detect_device
  end

  private

  def cannot_report_self
    reported = reportable.is_a?(Post) ? reportable.user : reportable
    errors.add(:base, "can't report self") if reported == reported_by
  end
end
