# frozen_string_literal: true

namespace :users do
  desc 'default acct_status for all users'
  task default_acct_status: :environment do
    User.update_all(acct_status: :active)
  end
end
