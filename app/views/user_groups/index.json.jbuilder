# frozen_string_literal: true

json.user_groups @groups, partial: 'user_groups/user_group', as: :user_group
json.total_pages @groups.total_pages
