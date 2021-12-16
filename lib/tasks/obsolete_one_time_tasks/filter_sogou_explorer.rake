# frozen_string_literal: true

namespace :filter do
  desc 'Filtering Sogou Explorer views/watchtime'
  task sogou_explorer: :environment do
    OneTimeJobs::FilterSogouExplorerJob.perform_later
  end
end
