# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    parent_id { nil }
    user
    category { Category.find_by(name: 'general') || create(:category) }
    sequence(:title) { |n| "p_#{n}" }
    description      { 'description 123' }
    video_length     { 12.34 }
    animated_cover   { File.open('public/test.mp4') }
    media_file       { File.open('public/test.mp4') }
    media_thumbnail  { File.open('public/takko.png') }
    takko_permission { 'private' }
    view_permission { 'private' }
    original_user_id { nil }
    upvotes_count { rand(1..100) }
    takkos_received { rand(1..100) }
    counted_watchtime { rand(1..100) }
    comments_count { rand(1..100) }

    trait :public do
      view_permission { :public }
      takko_permission { :public }
    end

    trait :followees do
      view_permission { :followees }
      takko_permission { :followees }
    end
  end
end
