# frozen_string_literal: true

namespace :external_accounts do
  desc 'default status for all external accounts'
  task default_status: :environment do
    ExternalAccount.update_all(archived: false)
  end
end
