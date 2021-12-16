# frozen_string_literal: true

class FeedController < ApplicationController
  def index
    @collection = Feeds::HomeService.new(user: @current_user, page_number: params[:page], feed_type: 'home').call

    return discover(type: 'home') if @collection.nil?

    render 'feed_response'
  end

  def discover(type: nil)
    @collection = Feeds::DiscoverService.new(session: @current_session, page_number: params[:page], app_id: request.headers['APP-ID']).call
    @collection[:type] = 'home' if type == 'home'
    render 'feed_response'
  end

  def explore
    @collection = Feeds::ExploreService.new(user: @current_user, page_number: params[:page], feed_type: 'explore', categories: params[:categories]).call
    render 'feed_response'
  end
end
