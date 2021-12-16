# frozen_string_literal: true

module Api
  module V1
    class BannersController < BaseController
      def index
        @collection = Banner.asc(:order).page(params[:page]).per(6)
      end
    end
  end
end
