# frozen_string_literal: true

class ReportsController < ApplicationController
  # TODO, once FE switch to use this endpoint, remove posts#report and profiles#report actions.
  def entity
    ReportsService.new(user: @current_user, request: request, params: params).call
    render json: { success: 'Thank you for reporting' }, status: :ok
  end
end
