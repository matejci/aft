# frozen_string_literal: true

module SendgridAutomation
  class UpsertContactJob < ApplicationJob
    queue_as :default

    def perform(user_id)
      Sendgrid::UpdateContacts.new([user_id]).call
    end
  end
end
