# frozen_string_literal: true

namespace :creator_programs do
  desc 'Opt users who already signed up for creator program before the gate'
  task opt_already_signed_up_users: :environment do
    already_existing = ConnectedAccount.where(:created_at.lte => CreatorProgram.max(:updated_at)).distinct(:user_id)

    User.in(id: already_existing).not(creator_program_opted: true).update_all(
      creator_program_opted: true, creator_program_opted_at: CreatorProgram.min(:created_at)
    )
  end
end
