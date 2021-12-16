# frozen_string_literal: true

class DeleteAccountsService
  def initialize(date: Date.current)
    @date = date
  end

  def call
    delete_accounts
  end

  private

  attr_reader :date

  def delete_accounts
    User.where(acct_status: :deactivated, removal_deactivation_at: date.all_day).each do |user|
      user.payouts.any? ? user.set(acct_status: :deleted) : user.destroy!
    end
  end
end
