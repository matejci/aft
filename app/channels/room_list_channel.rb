# frozen_string_literal: true

class RoomListChannel < ApplicationCable::Channel
  def subscribed
    if params[:user_id] != current_user.id.to_s
      ActionCable.server.remote_connections.where(current_user: current_user).disconnect
      return
    end

    # puts "#{current_user.username} subscribed."

    stream_from("room_list_for_#{current_user.id}")
  end

  def unsubscribed
    # puts "#{current_user.username} unsubscribed!"
  end

  def room_list(_data)
    WsBroadcastService.new(broadcaster: "room_list_for_#{current_user.id}", data: prepare_data, type: 'RoomList').call
  end

  private

  def prepare_data
    rooms = Room.where(:member_ids.in => [current_user.id])

    rooms.each_with_object([]) do |room, arr|
      room_obj = {
        id: room.id.to_s,
        name: room.name,
        generated_name: room.generated_name,
        created_by_id: room.created_by_id,
        created_at: room.created_at,
        updated_at: room.updated_at,
        last_read_messages: room.last_read_messages,
        members_count: room.members_count,
        room_thumb: room.room_thumb
      }

      if room.messages.any?
        room_obj[:last_message] = {
          id: room.messages.last.id.to_s,
          content: room.messages.last.content,
          message_type: room.messages.last.message_type,
          sender_id: room.messages.last.sender_id.to_s,
          created_at: room.messages.last.created_at,
          updated_at: room.messages.last.updated_at
        }
      end

      arr << room_obj
    end
  end
end
