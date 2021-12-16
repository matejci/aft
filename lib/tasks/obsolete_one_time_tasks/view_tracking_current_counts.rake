# frozen_string_literal: true

namespace :view_trackings do
  desc 'initialize default current_counts for view trackings'
  task current_counts_init: :environment do
    ViewTracking.update_all(current_counts: [])
  end
end
