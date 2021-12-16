# frozen_string_literal: true

namespace :connected_accounts do
  desc 'default status for all connected accounts'
  task default_status: :environment do
    ConnectedAccount.where(stripe_id: nil).update_all(status: :pending)
    ConnectedAccount.not(stripe_id: nil).no_timeout.each do |account|
      status = if account.payouts_enabled
        :enabled
      else
        case account.disabled_reason
        when nil, 'under_review', /^requirements/
          :pending
        when /^rejected/
          :denied
        else
          :disabled
        end
      end

      account.set(status: status)
    end
  end
end
