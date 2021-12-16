# frozen_string_literal: true

namespace :monetization_tracker do
  desc 'Enable monetization status update tracking'
  task init: :environment do
    ConnectedAccount.enable_tracking!
    User.enable_tracking!
  end
end
