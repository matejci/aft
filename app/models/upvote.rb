# frozen_string_literal: true

class Upvote < Vote
  belongs_to :post, optional: true, counter_cache: :upvotes_count
  belongs_to :comment, optional: true, counter_cache: :upvotes_count

  field :type, default: 'up'

  after_create  :touch_post_counts_updated_at
  after_destroy :touch_post_counts_updated_at

  private

  def touch_post_counts_updated_at
    return if post.blank?

    post.set(counts_updated_at: Time.current)
  end
end
