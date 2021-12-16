# frozen_string_literal: true

namespace :categories do
  desc 'Add two new categories'
  task add_qa_takko_community: :environment do
    Category.create!(name: 'Q&A')
    Category.create!(name: 'Takko Community')
  end
end
