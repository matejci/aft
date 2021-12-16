# frozen_string_literal: true

namespace :user do
  desc "Initialize users' watched items"
  task watched_items_init: :environment do
    User.active.includes(:configuration).all.no_timeout.each do |u|
      uc = u.configuration
      uc.set(watched_items: View.where(viewed_by_id: u.id).distinct(:post_id))
    end

    puts 'Finished.'
  end
end
