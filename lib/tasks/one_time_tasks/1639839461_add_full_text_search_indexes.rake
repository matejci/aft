# frozen_string_literal: true

namespace :db do
  desc 'Adding text search indexes for Post, User and Comment models'
  task full_text_search: :environment do
    %w[Post User Comment Report].each do |model|
      client = Mongoid.default_client[model.constantize.collection_name]
      client.indexes.create_one({ '$**' => 'text' })
    end

    puts 'Indexes created'
  end
end
