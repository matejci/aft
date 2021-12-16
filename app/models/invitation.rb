class Invitation
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user, optional: true
  belongs_to :subscriber, optional: true

  field :claimed_date, type: DateTime
  field :claimed, type: Boolean, default: false
  field :skip_claiming, type: Boolean, default: false

  field :ip_address, type: String
  field :user_agent, type: String
  field :invite_code, type: String

  # admin status
  field :status, type: Boolean, default: true
  field :email_sent, type: String # email invite sent to
  field :email_used, type: String # email used to sign up
  field :invited_by, type: String # user
  field :invited_type, type: String # referral, admin/system

  # invite registration attempts
  field :attempts, type: Array, default: []
  field :number_of_attempts, type: Integer, default: 0

  # user agent device detector
  field :device_name, type: String
  field :device_type, type: String
  field :device_client_name, type: String
  field :device_client_full_version, type: String
  field :device_os, type: String
  field :device_os_full_version, type: String
  field :device_client_known, type: Boolean

  validate :init, on: :create


  def init
    # check if unique and generate invite code
    self.invite_code = loop do
      token = SecureRandom.hex(5)
      break token unless Invitation.where(invite_code: token).exists?
    end
  end

  def claim
    unless self.claimed
      # track claim attempts
      self.number_of_attempts += 1

      self.claimed = true
      self.claimed_date = Time.now

      client = DeviceDetector.new(self.user_agent)
      self.device_name = client.device_name
      self.device_type = client.device_type
      self.device_client_name = client.name
      self.device_client_full_version = client.full_version
      self.device_os = client.os_name
      self.device_os_full_version = client.os_full_version
      self.device_client_known = client.known?
      self.save
      true
    else
      log_attempt
      save
      return false
    end
  end

  def log_attempt
    # track claim attempts
    self.number_of_attempts += 1

    self.attempts << {
      date: Time.now,
      date_formatted: Time.now.strftime("%b %e, %Y - %l:%M%P").to_s,
      ip_address: self.ip_address,
      user_agent: self.user_agent,
      email_used: self.email_used,
    }
  end
end
