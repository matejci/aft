# frozen_string_literal: true

class Configuration
  include Mongoid::Document
  include Mongoid::Timestamps

  field :curated_posts, type: Array, default: []
  field :ads, type: Hash, default: {}
  field :support, type: Hash, default: {}
  field :boost_list, type: Array, default: []
  field :boost_value, type: Integer, default: 2
  field :post_boost, type: Hash, default: { post_ids: [], boost_value: 1.0, expires_at: Time.current }
  field :monetization_enabled, type: Boolean, default: false

  belongs_to :app
end
