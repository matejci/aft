# frozen_string_literal: true

class SubscribersController < ApplicationController
  before_action :confirm_admin_logged_in, only: [:index, :destroy]
  before_action :set_subscriber, only: [:show, :edit, :update, :destroy]

  def share; end

  # GET /email/unsubscribe/:unsubscribe_hash
  def unsubscribe
    @subscriber = Subscriber.where(unsubscribe_hash: params[:unsubscribe_hash]).first
    if @subscriber.nil?
      redirect_to root_url
    else
      ip_address = request.remote_ip
      @subscriber.unsubscribe(ip_address)
    end
  end

  # GET /subscribers
  # GET /subscribers.json
  def index
    @subscribers = Subscriber.all.order_by([:created_at, :desc]).page(params[:page]).per(params[:limit])

    respond_to do |format|
      format.html { redirect_to '/admin', notice: 'Welcome to Admin Panel' }
      format.json { render :index, status: :ok }
    end
  end

  # GET /subscribers/1
  # GET /subscribers/1.json
  def show; end

  # GET /subscribers/new
  def new
    @subscriber = Subscriber.new
  end

  # GET /subscribers/1/edit
  def edit; end

  # POST /subscribers
  # POST /subscribers.json
  def create
    @subscriber = Subscriber.new(subscriber_params)
    @subscriber.ip_address = request.remote_ip
    @subscriber.user_agent = request.user_agent

    respond_to do |format|
      if @subscriber.save
        format.html { redirect_to @subscriber, notice: 'Subscriber was successfully created.' }
        format.json { render :show, status: :created }
      else
        format.html { render :new }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subscribers/1
  # PATCH/PUT /subscribers/1.json
  def update
    @subscriber.ip_address = request.remote_ip

    respond_to do |format|
      if @subscriber.update(subscriber_params)
        format.html { redirect_to @subscriber, notice: 'Subscriber was successfully updated.' }
        format.json { render :show, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @subscriber.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscribers/1
  # DELETE /subscribers/1.json
  def destroy
    @subscriber.destroy
    respond_to do |format|
      format.html { redirect_to subscribers_url, notice: 'Subscriber was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subscriber
    @subscriber = Subscriber.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def subscriber_params
    params.require(:subscriber).permit(:firstName, :lastName, :email, :phone, :mobile_device, :age, :newsletter, :referral, :triggerEmail)
  end
end
