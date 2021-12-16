# frozen_string_literal: true

json.array! @collection[:posts], partial: 'posts/custom_posts/custom_item', as: :custom_post
