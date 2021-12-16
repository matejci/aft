# frozen_string_literal: true

FactoryBot.define do
  factory :hashtag do
    name        { 'takko' }
    comment_ids { nil }
    post_ids { nil }
    category_id { nil }
    created_by_id { nil }
    link { 'takko' }
    status { true }
    takeover { false }
  end
end
