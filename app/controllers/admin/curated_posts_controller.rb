# frozen_string_literal: true

module Admin
  class CuratedPostsController < ApplicationController
    before_action :confirm_admin_logged_in
    before_action :set_config, only: [:update, :destroy]

    def index
      @collection = Admin::CuratedPostsService.new(page: params[:page]).call
    end

    def search
      @collection = Admin::SearchService.new(query: params[:query], page: params[:page]).call
    end

    def update
      new_post = BSON::ObjectId.from_string(params[:id])

      render json: { error: 'Post already exists in curated list' }, status: :unprocessable_entity and return if @config.curated_posts.include?(new_post)

      @config.curated_posts << new_post
      @config.save!

      render json: { id: params[:id] }, status: :ok
    end

    def destroy
      @config.curated_posts.delete(BSON::ObjectId.from_string(params[:id]))
      @config.save!

      render json: { id: params[:id] }, status: :ok
    end

    private

    def set_config
      @config = App.find_by(app_type: :ios).configuration
    end
  end
end
