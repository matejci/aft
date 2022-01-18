# frozen_string_literal: true

namespace :aft do
  desc 'Seed data'
  task seed: :environment do
    puts 'Seeding data'
    puts 'Apps...'

    App.find_or_create_by!(app_id: '17090582082047195423',
                           app_type: :web,
                           csrf: true,
                           description: 'Teachers web platform',
                           email: 'admin@takkoapp.com',
                           key: 'Td4PhXdWMzTBfc-DOrvp_3dJSHWMH1dhOFQYIZKcLgs0jkQ-xDxQM4OMl8fxCBY0bQA',
                           name: 'App For Teachers Web',
                           public_key: '20b43633b066d56150dc7894ce1ca76813d9f866d3ffd48ba7',
                           publish: false,
                           requests: 0,
                           secret: '2d0j5YHqNxnnBvn7OGedVU92AomhD6cAgDf6EOdw9L4THU96L7hUCaUub2eY0viIg_Q',
                           status: true)

    App.find_or_create_by!(app_id: '12171451176048326830',
                           app_type: :ios,
                           csrf: false,
                           description: 'App For Teachers iOS app',
                           email: 'admin@takkoapp.com',
                           key: 'nKZJcLXr_V_Nd89gAxgPVnQyzv1l13msKL-PCLnZ3hDvC8pbSbkwsHE21TIOrVp5OH4',
                           name: 'App For Teachers iOS',
                           public_key: '0b68924a696462acfa5f5a663ece24c52db099178b040babc2',
                           publish: false,
                           requests: 0,
                           secret: 'clricKZf_SnG0HdmwibY4qrc5693vIpKgHaX5HlteGXvCM464dETm3N4MnHX6ypjO7E',
                           status: true)

    App.find_or_create_by!(app_id: '85205862369669018330',
                           app_type: :android,
                           csrf: false,
                           description: 'App For Teachers Android app',
                           email: 'admin@takkoapp.com',
                           key: '5S5YpGI3ee-_h1gFvJ0NR-aaLJrJ4agLjxbcG4kjWBpBDNVUtgBvrSZEO1kn-ExuD30',
                           name: 'App For Teachers Android',
                           public_key: '347280026c4007f46229863ba4f8d30d42741c96716f86e259',
                           publish: false,
                           requests: 0,
                           secret: 'r2VgT7T5rRRBRvo_lJ-UzsmxxEsWG6lkEkxZFRzSrU1GP9v4N6Y9ng43-o9qP1_D-4k',
                           status: false)

    puts 'Categories...'

    [
      'Mental Health', 'Parent Stories', 'Student Stories',
      'Administration Talk', 'Teaching Resources', 'Aft Community',
      'New Teachers', 'Opportunities', 'Random', 'Aft Tutorial'
    ].each do |item|
      Category.find_or_create_by!(name: item)
    end

    puts 'AFT user...'

    u = User.first_or_create!(acct_status: :active,
                              admin: true,
                              admin_role: :administrator,
                              completed_signup: true,
                              display_name: 'AFT Offical',
                              dob: Date.new(1970, 1, 1).to_s,
                              email: 'admin@appforteachers.com',
                              email_verified_at: Time.current,
                              password: '123123!aft',
                              username: 'aftuser',
                              verified: true,
                              website: 'http://appforteachers.com')

    puts 'AFT user config...'

    conf = u.configuration
    conf.ads = { search_ads_enabled: true, search_ads_frequency: 5, discover_ads_enabled: true, discover_ads_frequency: 7 }
    conf.save!

    puts 'Subscribing to AWS topic...'
    AwsSubscription.subscribe!

    puts 'Finished!'
  end
end
