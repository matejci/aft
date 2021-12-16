class PoolIntervalsController < ApplicationController
  before_action :set_pool_interval, only: [:show, :edit, :update, :destroy, :process_interval]
  before_action :confirm_admin_logged_in

  # GET /pools
  # GET /pools.json
  def index
    @pools = Pool.all.desc(:start_date, :created_at).page(params[:page]).per(10)
  end

  # GET /pools/1
  # GET /pools/1.json
  def show
    @pool_interval.load_watch_times if @pool_interval.load_eligible?
  end

  # GET /pools/1/edit
  def edit
  end

  # PATCH/PUT /pools/1
  # PATCH/PUT /pools/1.json
  def update
    respond_to do |format|
      if @pool_interval.update(pool_interval_params)
        format.json { render :show, status: :ok, location: @pool_interval }
      else
        format.json { render json: @pool_interval.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pools/1
  # DELETE /pools/1.json
  def destroy
    @pool.destroy
    respond_to do |format|
      format.html { redirect_to pools_url, notice: 'Pool was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # NOTE: route name 'process' breaks the code
  def process_interval
    respond_to do |format|
      # TODO: mark as `bulk_editing`
      if @pool_interval.update(status: :processed, modified_by: @current_user)
        @pool_interval.reload # to load payout updates
        format.json { render :show, status: :ok, location: @pool_interval }
      else
        format.json { render json: @pool_interval.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_pool_interval
    @pool_interval = PoolInterval.find(params[:id])
  end

  def pool_interval_params
    params.require(:pool_interval).permit(
      :amount, :fixed, :watch_time_rate,
      payouts_attributes: [:id, :amount]
    ).merge(modified_by: @current_user)
  end
end
