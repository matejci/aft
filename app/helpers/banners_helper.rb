# frozen_string_literal: true

module BannersHelper
  def admin_nav_links
    nav_links = []

    %w[dashboard users content pools payouts subscribers invitations usernames curated_posts reports creator_program banners].each do |item|
      href = case item
             when 'dashboard'
               '/admin/studio'
             when 'users', 'content', 'pools', 'payouts', 'subscribers', 'invitations', 'usernames'
               "/admin/studio/#{item}"
             else
               "/admin/#{item}"
      end

      class_name = 'nav-link'
      class_name += ' active' if current_page?(href)

      nav_link = content_tag :li, class: 'nav-item' do
        content_tag :a, class: class_name, href: href do
          item.titleize
        end
      end

      nav_links << nav_link
    end

    safe_join(nav_links)
  end
end
