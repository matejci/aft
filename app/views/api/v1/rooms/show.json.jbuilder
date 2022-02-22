# frozen_string_literal: true

json.data do
  json.room do
    json.extract!(@collection[:room], :id, :name, :generated_name, :created_by_id, :created_at, :updated_at, :last_read_messages, :members_count, :room_thumb)

    json.members do
      json.array!(@collection[:members], :id, :username, :display_name, :email, :phone, :verified, :profile_thumb_url, :first_name, :last_name)
    end

    json.messages do
      json.array!(@collection[:messages], :id, :content, :sender_id, :message_type, :created_at, :updated_at, :payload)
    end
  end
end
