# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :confirm_user_logged_in, except: :aws

  def index
    @notifications = PushNotifications::IndexService.new(user: @current_user, page: params[:page]).call
  end

  def mark_as_read
    @current_user.notifications.unread.update_all(read_at: Time.zone.now)
    response.set_header('UNREAD-NOTIFICATIONS-COUNT', 0)
    Notification.expire_unread_count(@current_user.id)
    render json: { success: 'Marked as read' }, status: :ok
  end

  def aws
    Aws::NotificationsProcessorService.new(data: request.raw_post).call
  end
end
