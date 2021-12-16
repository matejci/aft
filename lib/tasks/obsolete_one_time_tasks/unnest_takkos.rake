# frozen_string_literal: true

namespace :posts do
  desc 'Unnest takkos so takko does not belong to other takko'
  task unnest_takkos: :environment do
    Post.in(id: Post.distinct(:parent_id)).not(parent_id: nil).no_timeout.each do |nested_takko|
      Post.where(parent_id: nested_takko.id).update_all(parent_id: nested_takko.parent_id)
    end
  end
end
