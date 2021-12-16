# frozen_string_literal: true

json.upvotes_count model_object.reload.upvotes_count
json.voted         Vote.find_for(model_object, @current_user)
