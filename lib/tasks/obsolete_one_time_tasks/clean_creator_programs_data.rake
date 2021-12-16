# frozen_string_literal: true

namespace :creator_programs do
  desc 'Clean creator programs data: user monetization status, unmatched business type'
  task clean_data: :environment do
    user_ids = ConnectedAccount.active.includes(:user).no_timeout.each_with_object([]) do |account, ids|
      # fix phone format
      account.set(phone: "+1-#{account.phone}") if account.phone.present? && !account.phone.match?(/^\+/)

      next if account.stripe_id.blank?
      stripe = Stripe::Account.retrieve(account.stripe_id)

      # fix unmatched business type
      stripe = Stripe::Account.update(account.stripe_id, business_type: account.business_type) if stripe.business_type.nil?

      Connectedaccount::UpdateService.new(account: account, stripe: stripe).call
      ids << account.user_id
    rescue Stripe::PermissionError => e
      account.destroy # removes account that has stripe id from wrong env
    end

    User.not_in(id: user_ids).update_all(monetization_status: false, monetization_status_type: :not_started)
  end
end
