# frozen_string_literal: true

class WsBroadcastService
  def initialize(broadcaster:, data:, type:)
    @broadcaster = broadcaster
    @data = data
    @type = type
  end

  def call
    ws_broadcast
  end

  private

  attr_reader :broadcaster, :data, :type

  def ws_broadcast
    ActionCable.server.broadcast(broadcaster, prepare_message)
  end

  def prepare_message
    {
      data: data,
      type: type
    }
  end
end
