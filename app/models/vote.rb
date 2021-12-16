# frozen_string_literal: true

class Vote
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, counter_cache: true
  belongs_to :post, optional: true
  belongs_to :comment, optional: true

  validates :post, uniqueness: { scope: :user, message: 'Vote already exists', allow_nil: true }
  validates :comment, uniqueness: { scope: :user, message: 'Vote already exists', allow_nil: true }

  validate :allowed_to_vote

  after_create  :expire_cache
  after_destroy :expire_cache

  def self.toggle(record, user)
    vote_hash = case record.class.to_s
                when 'Comment'
                  { comment: record, user: user }
                when 'Post'
                  { post: record, user: user }
    end

    vote = where(vote_hash).first

    if vote
      vote.destroy
    else
      Vote.where(vote_hash).destroy_all
      create!(vote_hash)
    end
  end

  def self.find_for(model_object, user)
    klass = model_object.class.to_s.downcase
    cache_key = "votes_#{klass}_#{model_object.id}_#{user.id}"

    query_hash = case klass
                 when 'comment'
                   { comment: model_object, user: user }
                 when 'post'
                   { post: model_object, user: user }
    end

    Rails.cache.fetch(cache_key) do
      where(query_hash).first&.type
    end
  end

  private

  def allowed_to_vote
    errors.add(:base, 'Not allowed to vote') if post.present? && Block.exists_for?(post.user, user)
    errors.add(:base, 'Not allowed to vote') if comment.present? && Block.exists_for?(comment.user, user)
  end

  def expire_cache
    Rails.cache.delete("votes_post_#{post.id}_#{user_id}") if post.present?
    Rails.cache.delete("votes_comment_#{comment_id}_#{user_id}") if comment.present?
  end
end
