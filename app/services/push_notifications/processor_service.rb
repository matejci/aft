# frozen_string_literal: true

# rubocop: disable Metrics/CyclomaticComplexity
module PushNotifications
  class ProcessorService
    def initialize(action:, notifiable:, actor:, recipient:, body: nil)
      @action = action
      @notifiable = notifiable
      @actor = actor
      @recipient = recipient
      @body = body
    end

    def call
      return send_dm_notification if notifiable.is_a?(Room)
      return unless should_send_notification?

      send_notification(create_notification)
    end

    private

    attr_reader :action, :notifiable, :actor, :recipient, :body

    def should_send_notification?
      return if actor.id == recipient.id

      conf = recipient.configuration
      settings = conf.push_notifications_settings[action]

      case action
      when :upvoted, :added_takko, :commented, :mentioned
        return unless settings.in?(%w[everyone following])
        return if action == :added_takko && conf.carousel_notifications_blacklist.include?(notifiable.parent.id.to_s)
        return recipient.followees_ids.include?(actor.id.to_s) if settings == 'following'
      when :followed, :payout, :followee_posted
        return settings == 'on'
      end

      true
    end

    def create_notification
      model = action == :payout ? 'payout_notifications' : 'notifications'

      notifiable.public_send(model).find_or_create_by(actor: actor, recipient: recipient, action: action,
                                                      headings: headings, description: description, image_url: image_url,
                                                      notifiable_url: notifiable_url)
    end

    def headings # rubocop:disable Metrics/PerceivedComplexity
      if action == :upvoted
        usernames = notifiable.notifications.upvoted.unread.for(notifiable.user).includes(:actor).desc(:created_at).map { |n| n.actor.username }

        case usernames.size
        when 0
          actor.username
        when 1
          "#{usernames.first} and #{actor.username}"
        when 2
          "#{usernames.join(', ')} and #{actor.username}"
        else
          "#{actor.username}, #{usernames.pop} and #{usernames.size} #{'other'.pluralize(usernames.size)}"
        end
      elsif action == :payout && body.nil?
        'You just got paid! 💰'
      elsif action == :payout
        'You earned 💰!'
      else
        actor.username
      end
    end

    def description
      case action
      when :followed
        'followed you'
      when :mentioned
        description = ['mentioned you in']
        description << (notifiable.model_name.human.casecmp('post').zero? ? mentioned_description : "comment: #{notifiable.text}")
        description.join(' ')
      when :commented
        "left a comment: #{notifiable.text}"
      when :added_takko
        "added a video to a carousel you follow: #{notifiable.parent.description.truncate(30)}"
      when :upvoted
        post_type = notifiable.takko? ? 'Response' : 'Post'

        "upvoted your #{post_type}"
      when :payout
        if body.nil?
          'Congrats! Your payout earnings are on the way to your paypal account!'
        else
          "Congrats! You earned $#{body} so far!"
        end
      when :followee_posted
        followee_posted_description
      end
    end

    def image_url
      return '' if action == :payout

      img = case action
            when :followed
              actor.profile_image
            else
              obj = notifiable.is_a?(Post) ? notifiable : notifiable.post
              obj.media_thumbnail
      end

      img.thumb.url || ''
    end

    def notifiable_url
      case action
      when :followed
        actor.follow_url
      when :payout
        ''
      else
        notifiable.link_url
      end
    end

    def mentioned_description
      description = notifiable.description.truncate(30)
      notifiable.takko? ? "a response: #{description}" : "a post: #{description}"

      notifiable.takko? ? 'a response' : 'a post'
    end

    def followee_posted_description
      description = notifiable.description.truncate(30)

      if notifiable.takko?
        "added a video to #{notifiable.parent.user.username}'s post: #{description}"
      else
        "made a post: #{description}"
      end
    end

    def send_notification(notification)
      PushNotifications::PnSenderJob.perform_later(notification_id: notification.id.to_s)
    end

    def send_dm_notification
      OneSignalNotificationService.new(
        user: recipient,
        ios_sound: 'takko.wav',
        headings: { en: actor.username },
        contents: { en: "just sent a direct message to: #{notifiable.name || notifiable.generated_name}" },
        ios_attachments: { image_url: actor.profile_image.url },
        data: { notifiable_url: "#{Rails.application.routes.url_helpers.root_url}rooms/#{notifiable.id}/messages/#{body}" },
        collapse_id: nil,
        ios_badgeCount: recipient.unread_notifications_count,
        ios_badgeType: 'SetTo'
      ).call
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity
