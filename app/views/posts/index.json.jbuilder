# restored from https://github.com/Content-Creators/takko-web/commit/19d162d75e03bd556aab94f678f488ab4886ce9d#diff-5f029f8c516c00074d1360d025f42605
# to make React components work :)
# TODO, refactor/remove this

json.set! :posts do
  json.array! @posts do |post|
    json.extract! post, :_id, :title, :description, :publish_date, :link, :link_title, :created_at, :media_file, :media_thumbnail, :media_type

    json.set! :created_at, post.created_at.strftime("%b %e, %Y - %l:%M%P").to_s
    # unless post.email_delivery_date.nil?
    #   json.set! :email_delivery_date, post.email_delivery_date.strftime("%b %e, %Y - %l:%M%P").to_s
    # else
    #   json.set! :email_delivery_date, nil
    # end

    unless post.user_id.nil?
      user = User.find(post.user_id)
      json.set! :user do
        json.extract! user, :_id, :first_name, :last_name, :username, :profile_image
      end
    else
      json.set! :user, nil
    end

    # unless post.parent_id.nil?
    #   referred_post = Subscriber.find(post.parent_id)
    #   json.set! :referred_by, referred_post.email
    # else
    #   json.set! :referred_by, nil
    # end

    json.set! :items do
      json.array! post.takkos do |item|
        json.extract! item, :_id, :title, :description, :publish_date, :link, :link_title, :created_at, :media_file, :media_thumbnail, :media_type

        json.set! :created_at, item.created_at.strftime("%b %e, %Y - %l:%M%P").to_s

        unless item.user_id.nil?
          user = User.find(item.user_id)
          json.set! :user do
            json.extract! user, :_id, :first_name, :last_name, :username
          end
        else
          json.set! :user, nil
        end
      end
    end
  end
end

json.set! :postsTotal, @posts.total_count
json.set! :postsTotalPages, @posts.total_pages
