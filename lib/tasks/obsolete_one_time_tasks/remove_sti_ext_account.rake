# frozen_string_literal: true

namespace :external_account do
  desc 'remove sti _type on external account'
  task remove_sti_type: :environment do
    ExternalAccount.update_all(_type: nil)
  end
end
