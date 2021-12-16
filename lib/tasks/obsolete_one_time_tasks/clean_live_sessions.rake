# frozen_string_literal: true

namespace :sessions do
  desc 'Clean live sessions'
  task clean_live: :environment do
    Session.live.not(player_id: nil).desc(:last_activity).group(
      _id: '$player_id',
      latest: { '$first': '$$ROOT' },
      count: { '$sum': 1 }
    ).match(
      count: { '$gt': 1 }
    ).project(
      _id: 0, player_id: '$_id', latest_session: '$latest._id'
    ).aggregate.each do |result|
      Session.live.where(player_id: result['player_id']).not(id: result['latest_session']).update_all(live: false)
    end
  end
end
