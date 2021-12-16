# frozen_string_literal: true

class AutocompleteController < ApplicationController
  def hashtags
    @hashtags = AutocompleteHashtagService.new(query: params[:query]).call
  end

  def usernames
    @users = AutocompleteUsernameService.new(
      user: @current_user, post_id: params[:post_id], query: params[:query]
    ).call
  end
end
