# frozen_string_literal: true

namespace :external_accounts do
  desc 'Clean external accounts data: remove duplicate active accounts'
  task clean_data: :environment do
    # clean up 2+ active connected accounts
    ConnectedAccount.active.group(
      _id: '$user_id',
      count: { '$sum': 1 },
    ).match({ count: { '$gte': 2 }}).aggregate.each do |result|
      user = User.find(result['_id'])
      current_active = user.connected_account
      user.connected_accounts.not(id: current_active.id).set(archived: true, archived_at: Time.current)
    end

    # seed user_id on external accounts
    ExternalAccount.where(user_id: nil).includes(:connected_account).no_timeout.each do |ext_acct|
      ext_acct.set(user_id: ext_acct.connected_account&.user_id)
    end

    ExternalAccount.active.group(
      _id: '$connected_account_id',
      count: { '$sum': 1 }
    ).match({ count: { '$gte': 2 }}).aggregate.each do |result|
      connected_account = ConnectedAccount.find(result['_id'])
      current_active = connected_account.external_account

      if current_active.stripe_ext_id.present?
        begin
          current_bank = Stripe::Account.retrieve_external_account(connected_account.stripe_id, current_active.stripe_ext_id)
          current_bank.default_for_currency = true
          current_bank.save
        rescue Stripe::InvalidRequestError => e
          Rails.logger.info("---- Error While Setting Default External Account: #{current_active.id} ----")
          Rails.logger.info('---- Stripe::InvalidRequestError ----')
          Rails.logger.info("---- #{e.message} ----")
        end
      end

      connected_account.external_accounts.each do |external_account|
        next if external_account == current_active

        begin
          ext_id = external_account.stripe_ext_id
          Stripe::Account.retrieve_external_account(connected_account.stripe_id, ext_id).delete if ext_id.present?
          external_account.destroy
        rescue Stripe::InvalidRequestError => e
          Rails.logger.info("---- Error While Deleting External Account: #{external_account.id} ----")
          Rails.logger.info('---- Stripe::InvalidRequestError ----')
          Rails.logger.info("---- #{e.message} ----")
          external_account.set(archived: true, archived_at: Time.current)
        end
      end
    end
  end
end
