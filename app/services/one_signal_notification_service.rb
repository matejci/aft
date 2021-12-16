# frozen_string_literal: true

class OneSignalNotificationService
  include ServiceErrorHandling

  def initialize(user:, **notification_params)
    @user = user
    @notification_params = notification_params
  end

  def call
    super { send }
  end

  private

  attr_reader :user, :notification_params

  def send
    raise ServiceError, 'no recipient' if user.nil?

    player_ids = user.sessions.live.ios.not(player_id: nil).distinct(:player_id)
    raise ServiceError, 'no live devices' if player_ids.empty?

    uri = URI.parse('https://onesignal.com/api/v1/notifications')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, 'Content-Type': 'application/json;charset=utf-8')
    request.body = {
      app_id: ENV['ONE_SIGNAL_APP_ID'],
      include_player_ids: player_ids
    }.merge(notification_params).to_json

    response = http.request(request)
    handle_error(request, response)
  end

  def handle_error(request, response)
    return unless response.code != '200' || JSON.parse(response.body)['errors']

    error = 'unsuccessful one signal notification!'
    Bugsnag.notify(error) do |report|
      report.severity = 'error'
      report.add_tab(
        :notification, { user_id: user.id, request_body: request.body, response_body: response.body }
      )
    end

    raise ServiceError, error
  end
end
