# frozen_string_literal: true

namespace :connected_accounts do
  desc 'Update connected account status for accounts with due'
  task update_status: :environment do
    accounts = ConnectedAccount.active.not(status: :pending, due: [])

    accounts.update_all(status: :pending)
    User.in(id: accounts.pluck(:user_id)).update_all(
      monetized_at: nil, monetization_status: false, monetization_status_type: :pending
    )
  end
end
