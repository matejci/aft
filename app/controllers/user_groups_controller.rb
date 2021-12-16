# frozen_string_literal: true

class UserGroupsController < ApplicationController
  before_action :confirm_user_logged_in
  before_action :set_group, only: %i[show update destroy]

  def index
    @groups = @current_user.user_groups.includes(:users).page(params[:page]).per(20)
  end

  def create
    @group = @current_user.user_groups.new(group_params)

    if @group.save
      render :show, status: :created
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  def show; end

  def update
    if @group.update(group_params)
      render :show
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @group.destroy
    head :ok
  end

  private

  def set_group
    @group = @current_user.user_groups.find(params[:id])
  end

  def group_params
    params.require(:user_group).permit(:name, user_ids: [])
  end
end
