json.extract! @creator_program, :active, :threshold
json.currently_taken @creator_program.participants.size
