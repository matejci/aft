# frozen_string_literal: true

namespace :sendgrid_automation do
  desc 'Upserts contacts into sendgrid'
  task :populate_contacts, [:list_id] => :environment do |_t, _args|
    user_ids = User.active.where.not(email: nil).pluck(:id)
    Sendgrid::UpdateContacts.new(user_ids).call
  end
end
