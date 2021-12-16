# frozen_string_literal: true

namespace :paypal_accounts do
  desc 'enable user monetization for existing paypal accounts'
  task enable_user_monetization: :environment do
    PaypalAccount.where(:email.ne => '').and(:email.ne => nil).includes(:user).no_timeout.each do |acc|
      user = acc.user
      user.monetization_status = true
      user.monetization_status_type = :enabled
      user.monetized_at = acc.created_at if user.monetization_status_changed?
      user.save(validate: false)
    end
  end
end
