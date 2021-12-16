# frozen_string_literal: true

namespace :creator_programs do
  desc 'Update monetization status for creator program'
  task update_monetization_status: :environment do
    user_ids = ConnectedAccount.active.includes(:user).no_timeout.each_with_object([]) do |account, ids|
      stripe = Stripe::Account.retrieve(account.stripe_id)
      Connectedaccount::UpdateService.new(account: account, stripe: stripe).call
      ids << account.user_id
    end

    User.not_in(id: user_ids).update_all(monetization_status: false, monetization_status_type: :not_started)
  rescue Stripe::PermissionError => e
    account.set(stripe_id: nil) # nullify accounts that belong to different stripe env
    Connectedaccount::ArchiveService.new(account: account).call
  end
end
