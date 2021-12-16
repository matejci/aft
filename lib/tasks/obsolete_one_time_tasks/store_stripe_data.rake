# frozen_string_literal: true

namespace :users do
  desc 'store stripe_id and stripe_ext_id before removing stripe'
  task store_stripe_data: :environment do
    User.in(id: ConnectedAccount.distinct(:user_id)).no_timeout.each do |user|
      user.set(
        stripe_ids: user.connected_accounts.not(stripe_id: nil).desc(:updated_at).pluck(:stripe_id),
        stripe_ext_ids: user.external_accounts.not(stripe_ext_id: nil).desc(:updated_at).pluck(:stripe_ext_id)
      )
    end
  end
end
