# frozen_string_literal: true

module Creatorprogram
  class OptInService
    class ThresholdReachedError < StandardError; end
    class CreatorProgramInactive < StandardError; end
    class UserNotFound < StandardError; end

    def initialize(cprogram:, user:, opt_in:)
      @cprogram = cprogram
      @user = user
      @opt_in = opt_in.in?([true, 'true'])
    end

    def call
      raise UserNotFound, 'Only logged users can opt-in' unless @user
      raise CreatorProgramInactive, 'Creator program is not active at the moment' unless cprogram.active

      process_opt_in
    end

    private

    attr_reader :cprogram, :user, :opt_in

    def process_opt_in
      if opt_in
        check_threshold
        cprogram.participants << user.id if cprogram.participants.exclude?(user.id)
      else
        cprogram.participants.delete(user.id)
      end

      user.creator_program_opted = opt_in
      user.creator_program_opted_at = Time.current
      user.save!
      cprogram.save!

      deactivate_program if cprogram.participants.size == cprogram.threshold
    end

    def check_threshold
      valid = cprogram.threshold > cprogram.participants.size

      raise ThresholdReachedError, 'Creator Program threshold reached' unless valid
    end

    def deactivate_program
      cprogram.set(active: false, participants: [])
    end
  end
end
