# frozen_string_literal: true

class Share
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :post, counter_cache: :shares_count
  belongs_to :user
end
