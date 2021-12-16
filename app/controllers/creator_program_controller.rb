# frozen_string_literal: true

class CreatorProgramController < ApplicationController
  before_action :load_creator_program

  def status; end

  def opt_in
    Creatorprogram::OptInService.new(cprogram: @creator_program, user: @current_user, opt_in: opt_in_params[:opt_in]).call
    head :ok
  end

  private

  def opt_in_params
    params.require(:creator_program).permit(:opt_in)
  end

  def load_creator_program
    @creator_program = CreatorProgram.first
  end
end
