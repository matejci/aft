# frozen_string_literal: true

namespace :aft do
  desc 'Seed data'
  task seed: :environment do
    puts 'Seeding data'

    App.create!()
  end
end
