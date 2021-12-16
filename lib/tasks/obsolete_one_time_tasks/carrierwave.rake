# frozen_string_literal: true

namespace :carrierwave do
  desc 'Update Carrierwave versions'
  task update_versions: :environment do
    OneTimeJobs::CarrierwaveJob.perform_later
  end
end
