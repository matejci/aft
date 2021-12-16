# frozen_string_literal: true

json.id user.dig('_id', '$oid')
json.username user['username']
json.display_name user['display_name']
json.profile_thumb_url user.dig('profile_image', 'thumb', 'url')
json.profile_image_version user['profile_image_version'] # TODO, check why/if is this needed?
json.verified user['verified']
