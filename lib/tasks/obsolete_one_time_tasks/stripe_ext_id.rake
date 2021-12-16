# frozen_string_literal: true

namespace :external_account do
  desc 'rename stripe_external_account_id to stripe_ext_id'
  task stripe_ext_id: :environment do
    ExternalAccount.not(stripe_external_account_id: nil).no_timeout.each do |e|
      e.set(stripe_ext_id: e.stripe_external_account_id)
    end
  end
end
