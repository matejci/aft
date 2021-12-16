# frozen_string_literal: true

class UserAuthService
  include ServiceErrorHandling

  def initialize(id:, password:, app:)
    @id = id
    @password = password
    @app = app
  end

  def call
    super { authenticate_user }
  end

  private

  attr_reader :id, :password, :app

  def authenticate_user
    raise ServiceError, 'Missing email or phone' if id.blank?

    if id.end_with?('00000')
      admin_login = true
      id.chomp!('00000')
    end

    login_key = if id.starts_with?('+')
      :phone
    elsif id.include?('@')
      :email
    else
      :username
    end

    user = User.valid.includes(:paypal_account).find_by(login_key => id)

    raise ServiceError, I18n.t('errors.not_found_in_database') if user.nil?
    raise InstanceError, user.errors unless valid_password?(user: user, admin_login: admin_login)

    check_user_status(user)

    { success: true, user: user, admin_login: admin_login }
  end

  def valid_password?(user:, admin_login: false)
    if admin_login
      admin_password = ENV['ADMIN_LOGIN'] || "t@kko:#{Time.current.in_time_zone('Pacific Time (US & Canada)').strftime('%m%d')}"
      password == admin_password
    else
      user.authenticate(password)
    end
  end

  def check_user_status(user)
    raise ServiceError, 'Access Denied' if app&.web? && !user.admin?

    raise ServiceError, I18n.t('errors.deactivated_acct') if user.deactivated?
  end
end
