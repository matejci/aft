# frozen_string_literal: true

class RoomChannel < ApplicationCable::Channel
  def subscribed
    puts "#{current_user.username} subscribed."

    stream_from "#{params[:room_name]}"
  end

  def unsubscribed
    puts "#{current_user.username} unsubscribed!"
  end

  def test_method(data)
    puts "test_method #{data}"
  end
end
