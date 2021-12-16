# frozen_string_literal: true

# desc 'process pool'
# task process_pool: :environment do
#   puts 'processing pool...'
#   CronJobs.process_pool!
#   puts 'done processing!'
# end

desc 'count views'
task count_views: :environment do
  puts 'counting views...'
  CronJobs.count_views!
  puts 'done counting!'
end

# desc 'process payout'
# task process_payout: :environment do
#   puts 'processing payout...'
#   CronJobs.process_payout!
#   puts 'done processing payout!'
# end

desc 'delete accounts'
task delete_accounts: :environment do
  puts 'deleting accounts...'
  CronJobs.delete_accounts!
  puts 'done deleting accounts!'
end

desc 'reset watched items'
task reset_watched_items: :environment do
  puts 'Reseting watched items...'
  CronJobs.reset_watched_items!
  puts 'Finished.'
end

desc 'Generate badges'
task generate_badges: :environment do
  puts 'Generating badges started...'
  CronJobs.generate_badges!
  puts 'Finished.'
end
