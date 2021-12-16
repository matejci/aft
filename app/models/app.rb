# frozen_string_literal: true

class App
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum

  EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i.freeze

  field :last_activity, type: DateTime

  field :app_id, type: String
  field :name, type: String
  field :description, type: String
  field :version, type: String, default: '1.0.0'
  field :email, type: String
  field :phone, type: String
  field :namespace, type: String
  field :public_key, type: String
  field :key, type: String
  field :secret, type: String
  field :privacy_policy_url, type: String
  field :terms_of_service_url, type: String

  field :permissions, type: Array, default: []
  field :access, type: Array, default: []
  field :supported_versions, type: Array, default: []
  field :domains, type: Array, default: []
  field :user_agent_whitelist, type: Array, default: []
  field :user_agent_blacklist, type: Array, default: []
  field :ip_whitelist, type: Array, default: []
  field :ip_blacklist, type: Array, default: []

  field :requests, type: Integer, default: 0

  field :status, type: Boolean, default: false
  field :publish, type: Boolean, default: false
  field :csrf, type: Boolean, default: false

  enum  :app_type, %i[web ios android]

  validates :email, length: { maximum: 150 }, confirmation: true
  validates :email, format: { with: EMAIL_REGEX, message: 'Please enter a valid email address' }
  validates :email, presence: { message: '' }

  validates :name, presence: { message: 'App name required' }
  validates :description, presence: { message: 'App description required' }
  validates :app_type, presence: { message: 'App type required' }
  validates :app_id, uniqueness: true

  # validate :init, on: :create
  validate :email_downcase

  has_many :sessions, dependent: :delete_all
  has_one :configuration, dependent: :destroy

  def init
    # initiate app keys
    self.app_id ||= loop do
      token = SecureRandom.random_number(10_000_000_000_000_000_000..99_999_999_999_999_999_999)
      break token unless App.where(app_id: token).exists?
    end

    # set unique keys and secrets
    self.public_key = loop do
      token = SecureRandom.hex(25)
      break token unless App.where(public_key: token).exists?
    end

    self.key = loop do
      token = SecureRandom.urlsafe_base64(50, false)
      break token unless App.where(key: token).exists?
    end

    self.secret = loop do
      token = SecureRandom.urlsafe_base64(50, false)
      break token unless App.where(secret: token).exists?
    end
  end

  def email_downcase
    return if email.blank?

    self.email = email.downcase
  end
end
