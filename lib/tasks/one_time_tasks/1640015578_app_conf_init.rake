# frozen_string_literal: true

namespace :configurations do
  desc 'Create configurations for apps'
  task init: :environment do
    App.all.each(&:create_configuration)
  end
end
