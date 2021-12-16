# frozen_string_literal: true

namespace :categories do
  desc "Adds new 'Takko Tutorial' category"
  task tutorial: :environment do
    Category.where(name: 'Takko Tutorial', link: 'takko-tutorial', status: true).first_or_create
  end
end
