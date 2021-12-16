# frozen_string_literal: true

# rubocop: disable Metrics/CyclomaticComplexity
namespace :notifications do
  desc 'Update notifications'
  task update: :environment do
    User.all.no_timeout.each do |user|
      notifications = Notification.for(user).includes(:notifiable, :actor).last_three_month.desc(:created_at)

      notifications.each do |notification|
        notification.set(headings: prepare_headings(notification),
                         description: prepare_description(notification),
                         image_url: prepare_image_url(notification),
                         notifiable_url: prepare_notifiable_url(notification))
      end
    end
  end
end

def prepare_headings(notification)
  return 'You just got paid! 💰' if notification.action == :payout

  if notification.action == :upvoted
    notifiable = notification.notifiable
    usernames = notifiable.notifications.upvoted.unread.for(notifiable.user).includes(:actor).desc(:created_at).map { |n| n.actor.username }

    case usernames.size
    when 0
      actor.username
    when 1
      "#{usernames.first} and #{notification.actor.username}"
    when 2
      "#{usernames.join(', ')} and #{notification.actor.username}"
    else
      "#{notification.actor.username}, #{usernames.pop} and #{usernames.size} #{'other'.pluralize(usernames.size)}"
    end
  else
    notification.actor.username
  end
end

def prepare_description(notification)
  case notification.action
  when :followed
    'followed you'
  when :mentioned
    description = ['mentioned you in']
    description << (notification.notifiable.model_name.human.casecmp('post').zero? ? mentioned_description(notification.notifiable, notification.recipient) : "comment: #{notification.notifiable.text}")
    description.join(' ')
  when :commented
    "left a comment: #{notification.notifiable.text}"
  when :added_takko
    "added a takko to a carousel you follow: #{notification.notifiable.parent.title}"
  when :upvoted
    post_type = notification.notifiable.takko? ? 'Takko' : 'Post'

    "upvoted your #{post_type}"
  when :payout
    'Congrats! Your payout earnings are on the way to your bank account!'
  when :followee_posted
    followee_posted_description(notification.notifiable)
  end
end

def prepare_image_url(notification)
  return '' if notification.action == :payout

  img = case notification.action
        when :followed
          notification.actor.profile_image
        else
          obj = notification.notifiable.is_a?(Post) ? notification.notifiable : notification.notifiable.post
          obj.media_thumbnail
  end

  img.thumb.url
end

def prepare_notifiable_url(notification)
  case notification.action
  when :followed
    notification.actor.follow_url
  when :payout
    nil
  else
    notification.notifiable.link_url
  end
end

def mentioned_description(notifiable, recipient)
  return "their title: #{notifiable.title}" if notifiable.title.include?("@#{recipient.username}")

  notifiable.takko? ? "a takko: #{notifiable.description.truncate(60)}" : "a post: #{notifiable.description.truncate(60)}"
end

def followee_posted_description(notifiable)
  if notifiable.takko?
    "added a takko to #{notifiable.parent.user.username}'s post: #{notifiable.parent.title}"
  else
    "made a post: #{notifiable.title}"
  end
end
# rubocop: enable Metrics/CyclomaticComplexity
