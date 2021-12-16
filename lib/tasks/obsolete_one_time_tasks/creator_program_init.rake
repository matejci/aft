# frozen_string_literal: true

namespace :creator_program do
  desc 'Creates creator program'
  task init: :environment do
    CreatorProgram.first_or_create
  end
end
