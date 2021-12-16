# frozen_string_literal: true

class RemoveAccountService
  include ServiceErrorHandling

  def initialize(user:, password:, remote_ip:, user_agent:)
    @user = user
    @password = password
    @remote_ip = remote_ip
    @user_agent = user_agent
  end

  def call
    super { remove_account }
  end

  private

  attr_reader :user, :password, :remote_ip, :user_agent

  def remove_account
    raise InstanceError, user.errors unless user.authenticate(password)

    user.acct_status = :deactivated
    user.removal_requested_at = Time.current
    user.removal_deactivation_at = user.removal_requested_at + 30.days
    user.removal_ip_address = remote_ip
    user.removal_user_agent = user_agent
    user.removal_reason = :user_requested
    user.save(validate: false)

    user.sessions.live.set(live: false)
    user.posts.set(active: false, archived: true, archived_at: user.removal_requested_at)
    user.posts.reindex
    user.reindex

    SendgridAutomation::UpsertContactJob.perform_later(user.id.to_s)

    { success: true }
  end
end
