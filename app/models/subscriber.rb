# frozen_string_literal: true

class Subscriber
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  belongs_to :parent, optional: true, class_name: 'Subscriber'

  field :firstName, type: String
  field :lastName, type: String
  field :email, type: String
  field :age, type: String
  field :phone, type: String
  field :device, type: String
  field :ip_address, type: String
  field :user_agent, type: String

  # position in line
  field :position, type: Integer
  # position rand number
  field :position_growth, type: Integer
  field :queue, type: Integer # original position queue

  field :link, type: String # share link

  field :newsletter, type: Boolean, default: true # newsletter subscription

  field :status, type: Boolean, default: false # invite status
  field :invite, type: String, default: proc { init_invite_code } # invite code/hash

  field :unsubscribe_status, type: Boolean, default: false
  field :unsubscribe_hash, type: String, default: proc { set_unsubscribe_hash }
  field :unsubscribe_date, type: DateTime
  field :unsubscribe_ip_address, type: String

  field :email_delivery_status, type: Boolean, default: false
  field :email_delivery_date, type: DateTime

  # user agent device detector
  field :device_name, type: String
  field :device_type, type: String
  field :device_client_name, type: String
  field :device_client_full_version, type: String
  field :device_os, type: String
  field :device_os_full_version, type: String
  field :device_client_known, type: Boolean

  enum :mobile_device, %i[iPhone Android]

  attr_accessor :referral, :triggerEmail

  with_options on: :update do
    validates :firstName, presence: { message: 'Please enter your first name' }
    validates :lastName, presence: { message: 'Please enter your last name' }
    validates :mobile_device, presence: { message: 'Please select your device' },
                              if: :mobile_device_changed?
  end

  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i.freeze
  validates :email, length: { maximum: 150 }, confirmation: true
  validates :email, format: { with: EMAIL_REGEX, message: 'Please enter a valid email address' }
  validates :email, presence: { message: '' }, on: :create
  validates :email, uniqueness: { case_sensitive: false, message: 'This email is already on the waitlist' }

  validate :email_downcase
  validate :set_share_link, on: :create
  validate :share_link_update, on: :update
  validate :set_position, on: :create
  validate :track_referral, on: :create
  validate :parse_device, if: proc { |u| u.user_agent_changed? }

  before_update :trigger_email

  def parse_device
    client = DeviceDetector.new(user_agent)
    self.device_name = client.device_name
    self.device_type = client.device_type
    self.device_client_name = client.name
    self.device_client_full_version = client.full_version
    self.device_os = client.os_name
    self.device_os_full_version = client.os_full_version
    self.device_client_known = client.known?
  end

  # track email referrals from share link
  def subscribers
    Subscriber.where(parent_id: id)
  end

  def track_referral
    return if referral.blank?

    subscriber_referral = Subscriber.find_by(link: referral)
    self.parent_id = subscriber_referral._id unless subscriber_referral.nil?
  end

  def trigger_email
    return unless triggerEmail && !email_delivery_status

    self.email_delivery_status = true
    self.email_delivery_date = Time.current
    UserMailer.waitlist(self).deliver
  end

  def unsubscribe(ip_address)
    self.unsubscribe_status = true
    self.unsubscribe_date = Time.zone.now
    self.unsubscribe_ip_address = ip_address
    save
  end

  def set_position
    self.position_growth = SecureRandom.random_number(2..7)
    subscriber_all = Subscriber.all
    if subscriber_all.size.zero?
      positions = subscriber_all.sum(:position)
      positions = 9322 if positions.zero?
    else
      last_subscriber = subscriber_all.order_by(%i[queue asc]).last
      positions = last_subscriber.position
    end
    self.position = positions + position_growth
    self.queue = subscriber_all.size + 1
  end

  # initialize invite code and share link
  def init_invite_code
    self.invite = loop do
      random_token = SecureRandom.hex(3)
      break random_token unless Subscriber.where(invite: random_token).exists?
    end
  end

  # initialize unsubscribe hash link
  def set_unsubscribe_hash
    self.unsubscribe_hash = loop do
      random_token = SecureRandom.urlsafe_base64(75, false)
      break random_token unless Subscriber.where(unsubscribe_hash: random_token).exists?
    end
  end

  def email_downcase
    self.email = email.downcase
  end

  def set_share_link
    self.link = loop do
      share_link = SecureRandom.hex(3)
      break share_link unless Subscriber.where(link: share_link).exists?
    end
  end

  def share_link_update
    return unless firstName_changed?

    self.link = loop do
      share_link = firstName.parameterize(separator: '') + SecureRandom.random_number(1000..9999).to_s
      break share_link unless Subscriber.where(link: share_link).exists?
    end
  end
end
