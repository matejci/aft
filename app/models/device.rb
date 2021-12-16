class Device
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, optional: true
  has_many :views
  has_many :watch_times

  field :ip_address, type: String
  field :user_agent, type: String

  field :name, type: String
  field :type, type: String

  field :client_name, type: String
  field :client_full_version, type: String
  field :client_os_name, type: String
  field :client_os_full_version, type: String
  field :client_known, type: Boolean

  attr_accessor :request

  validates :ip_address, :user_agent, presence: true
  validates :user, uniqueness: { scope: [:ip_address, :user_agent] }

  after_initialize :initialize_from_request, :detect_device

  def self.for(request, user = nil)
    where(
      user_agent: request.user_agent, ip_address: request.remote_ip, user: user
    ).first_or_create!
  end

  # after initialize

  def initialize_from_request
    return unless request.present?

    self.user_agent = request.user_agent
    self.ip_address = request.remote_ip
  end

  def detect_device
    return unless user_agent.present?

    client = DeviceDetector.new(user_agent)
    self.name                   = client.device_name
    self.type                   = client.device_type
    self.client_name            = client.name
    self.client_full_version    = client.full_version
    self.client_os_name         = client.os_name
    self.client_os_full_version = client.os_full_version
    self.client_known           = client.known?
  end
end
