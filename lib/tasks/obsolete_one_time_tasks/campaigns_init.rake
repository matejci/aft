# frozen_string_literal: true

namespace :campaigns do
  desc 'Create campaigns'
  task init: :environment do
    Campaign.find_or_create_by!(name: 'cryptotube')
    Campaign.find_or_create_by!(name: 'recipetube')
    Campaign.find_or_create_by!(name: 'kpopfam')
  end
end
