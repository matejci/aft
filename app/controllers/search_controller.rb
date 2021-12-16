# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @collection = Search::IndexService.new(query: params[:query], viewer: @current_user).call
  end

  def posts
    @collection = Search::PostsService.new(**search_params.to_h.symbolize_keys.merge(viewer: @current_user)).call
  end

  def users
    @collection = Search::UsersService.new(**search_params.to_h.symbolize_keys.merge(viewer: @current_user)).call
  end

  def hashtags
    @collection = Search::HashtagService.new(**search_params.to_h.symbolize_keys).call
  end

  private

  def search_params
    params.permit(:query, :page, :per_page)
  end
end
