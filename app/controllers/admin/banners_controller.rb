# frozen_string_literal: true

module Admin
  class BannersController < ApplicationController
    before_action :confirm_admin_logged_in
    before_action :set_banner, only: [:update, :destroy]

    def index
      @collection = Banner.asc(:order).page(params[:page]).per(6)
    end

    def create
      @banner = Banner.new(banner_params)
      if @banner.save
        render json: {}, status: :ok
      else
        render json: @banner.errors, status: :unprocessable_entity
      end
    end

    def update
      if @banner.update(banner_params)
        render json: {}, status: :ok
      else
        render json: @banner.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @banner.destroy
      head :ok
    end

    private

    def set_banner
      @banner = Banner.find(params[:id])
    end

    def banner_params
      params.require(:banner).permit(:link, :order, :image)
    end
  end
end
