# frozen_string_literal: true

class SubscribersController < ApplicationController
  before_action :confirm_admin_logged_in, only: :index
  before_action :set_subscriber, only: :update

  def share; end

  def index
    @subscribers = Subscriber.all.order_by([:created_at, :desc]).page(params[:page]).per(params[:limit])

    respond_to do |format|
      format.html { redirect_to '/admin', notice: 'Welcome to Admin Panel' }
      format.json { render :index, status: :ok }
    end
  end

  def create
    @subscriber = Subscriber.new(subscriber_params)
    @subscriber.ip_address = request.remote_ip
    @subscriber.user_agent = request.user_agent

    if @subscriber.save
      render :step_1
    else
      render 'errors'
    end
  end

  def update
    @subscriber.ip_address = request.remote_ip

    if @subscriber.update(subscriber_params)
      render step_resolver
    else
      render 'errors'
    end
  end

  private

  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  def subscriber_params
    params.require(:subscriber).permit(:email, :first_name, :last_name, :phone, :mobile_device, :age, :newsletter, :referral)
  end

  def step_resolver
    return :step_2 if params.dig(:subscriber, :first_name)
    return :step_3 if params.dig(:subscriber, :age)
  end
end
