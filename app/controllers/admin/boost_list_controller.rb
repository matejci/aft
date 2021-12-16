# frozen_string_literal: true

module Admin
  class BoostListController < ApplicationController
    before_action :confirm_admin_logged_in
    before_action :load_conf, only: [:add, :remove, :boost_value_update, :post_boost_value_update]

    def index
      @collection = Admin::BoostList::IndexService.new(page: params[:page]).call
    end

    def search
      @collection = Admin::BoostList::SearchService.new(query: params[:query], page: params[:page]).call
    end

    def add
      render json: { error: 'User not active' }, status: :bad_request and return unless User.active.find(params[:id])

      @conf.boost_list << params[:id]
      @conf.save!
      render json: { remove_url: admin_boost_list_remove_path(id: params[:id]) }, status: :ok
    end

    def remove
      @conf.boost_list.delete(params[:id])
      @conf.save!
      render json: { id: params[:id] }, status: :ok
    end

    def boost_value_update
      @conf.set(boost_value: params[:boost_value].to_i)
    end

    def post_boost_value_update
      @conf.post_boost['boost_value'] = params[:boost_value].to_f
      @conf.post_boost['expires_at'] = Time.current + 1.day
      @conf.save!

      render json: { valid_until: @conf.post_boost['expires_at'].strftime('%Y-%m-%d %H:%M') }, status: :ok
    end

    private

    def load_conf
      @conf = IosConfigService.new.call
    end
  end
end
