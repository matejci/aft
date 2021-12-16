# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :confirm_admin_logged_in

  def index
    redirect_to '/admin/studio'
  end

  def studio; end

  def users
    @users = if search_params[:query].present?
      User.search(search_params[:query])
    else
      User.desc(:created_at).page(params[:page]).per(10)
    end
  end

  def dashboard_metrics
    @users = User.all
    @posts = Post.original
    @takkos = Post.takko
    @views = View.all
  end

  def creator_program
    @creator_program = CreatorProgram.first
  end

  def creator_program_toggle
    @creator_program = Creatorprogram::AdminCpToggleService.new(active: params[:active], threshold: params[:threshold]).call
  end

  private

  def search_params
    params.permit(:query, :page, :per_page)
  end
end
