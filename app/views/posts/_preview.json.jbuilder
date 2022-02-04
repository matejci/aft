# frozen_string_literal: true

json.extract! post, :id, :category_id, :link, :total_views, :media_thumbnail_url, :media_file_url, :animated_cover_url, :counted_watchtime, :media_type

json.minimum_video_length Post::MINIMUM_VIDEO_LENGTH
