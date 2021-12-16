# frozen_string_literal: true

module Creatorprogram
  class AdminCpToggleService
    def initialize(active:, threshold: nil)
      @active = active == 'true'
      @threshold = threshold
    end

    def call
      toggle_creator_program
    end

    private

    attr_reader :active, :threshold

    def toggle_creator_program
      creator_program = CreatorProgram.first

      return { error: 'Must specify threshold' } if active && threshold.to_i.zero?

      creator_program.atomically do
        creator_program.set(active: active, threshold: threshold.to_i)
        creator_program.set(participants: []) unless active
      end

      creator_program
    end
  end
end
