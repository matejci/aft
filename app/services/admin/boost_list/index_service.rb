# frozen_string_literal: true

module Admin
  module BoostList
    class IndexService
      PER_PAGE = 10

      def initialize(page:)
        @page = page.presence || 1
      end

      def call
        boost_list
      end

      private

      attr_reader :page

      def boost_list
        conf = IosConfigService.new.call
        { users: User.active.where(:id.in => conf.boost_list).page(page).per(PER_PAGE), conf: conf }
      end
    end
  end
end
