# frozen_string_literal: true

json.data do
  json.room do
    json.extract!(@collection[:room], :id, :name, :created_by_id, :created_at, :updated_at, :last_read_messages)

    json.members do
      json.array!(@collection[:members], :id, :username, :display_name)
    end

    json.messages do
      json.array!(@collection[:messages], :id, :content, :sender_id, :message_type, :created_at, :payload)
    end
  end
end
