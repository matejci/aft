# frozen_string_literal: true

module Admin
  class ContestsController < ApplicationController
    before_action :confirm_admin_logged_in

    def index
      @collection = Contest.order_by(active: :desc)
    end

    def create
      post_identifier = params[:post_id]
      post = Post.or({ link: post_identifier }, { id: post_identifier }).first

      raise ActionController::BadRequest, 'Wrong post identifier' unless post

      Contest.create!(name: params[:name], post: post)
      redirect_to admin_contests_path
    end

    def update
      contest = Contest.active.first

      Contest.with_session do |session|
        session.start_transaction

        contest.post.set(takko_permission: :private)
        contest.winner = User.find_by(username: params[:username]) if params[:username]
        contest.archived_at = Time.current
        contest.active = false
        contest.save!

        session.commit_transaction
      end
    end
  end
end
