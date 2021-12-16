# frozen_string_literal: true

class FollowingsService
  FOLLOW_TYPES = %i[follower followee].freeze

  def initialize(user:, page:, follow_type:)
    @user = user
    @page = page.presence || 1
    @follow_type = follow_type
  end

  def call
    raise ActionController::BadRequest, 'Wrong follow_type' if FOLLOW_TYPES.exclude?(follow_type)

    follows
  end

  private

  attr_reader :user, :page, :follow_type

  def follows
    where_condition = follow_type == :follower ? :followee_id : :follower_id
    follows = Follow.includes(follow_type).where(where_condition => user.id).order(created_at: :desc).page(page).per(PER_PAGE[:follows])
    follows.each_with_object([]) { |follow, results| results << follow.send(follow_type) }
  end
end
