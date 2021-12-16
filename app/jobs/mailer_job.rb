# frozen_string_literal: true

class MailerJob < ApplicationJob
  queue_as :mailers
  sidekiq_options retry: false
end
