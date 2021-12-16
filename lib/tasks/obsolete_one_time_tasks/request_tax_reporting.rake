# frozen_string_literal: true

namespace :connected_accounts do
  desc 'Request tax reporting capability for existing connected accounts'
  task request_tax_reporting: :environment do
    ConnectedAccount.where.not(stripe_id: nil).no_timeout.each do |account|
      stripe = Stripe::Account.update(
        account.stripe_id,
        capabilities: { tax_reporting_us_1099_misc: { requested: true }, transfers: { requested: true }}
      )
      Connectedaccount::UpdateService.new(account: account, stripe: stripe).call
    rescue => e
      Rails.logger.error("RequestTaxReporting(#{account.stripe_id}) ERROR: #{e.message}")
    end
  end
end
