# frozen_string_literal: true

# rubocop: disable Rails/HelperInstanceVariable
module MetaTagsHelper
  def meta_tags
    case params[:controller]
    when 'profiles'
      title = "#{@user.display_name} (@#{@user.username}) | App For Teachers"

      description = if @user.bio.blank?
        "Follow @#{@user.username} on App For Teachers! See what other teachers are talking about and join the fun!".truncate(160, omission: '...')
      else
        @user.bio.truncate(160, omission: '...')
      end

      share_image_url = @user.profile_image.thumb.url
      og_url = "#{root_url}#{@user.username}"
    when 'posts'
      if @post.nil?
        title = ''
        description = ''
        share_image_url = ''
        og_url = ''
      else
        title = @post.post.description.size <= 25 ? "#{@post.post.description} | @#{@post.user.username}" : @post.post.description
        description = (@post.post.description.presence || "Watch @#{@post.user.username} on App For Teachers!").truncate(160, omission: '...')
        share_image_url = @post.post.media_thumbnail.original_thumb.url
        og_url = "#{root_url}p/#{@post.post.link}"
      end
    else
      title = 'App For Teachers'
      description = ''
      share_image_url = ''
      og_url = 'http://appforteachers.com'
    end

    {
      title: title,
      desc: description,
      fb_app_id: ENV.fetch('FB_APP_ID', ''),
      og_site_name: 'App For Teachers',
      og_title: title,
      og_desc: description,
      og_type: 'website',
      og_url: og_url,
      og_image: share_image_url,
      twitter_card: 'photo',
      twitter_image: share_image_url
    }
  end
end
# rubocop: enable Rails/HelperInstanceVariable
