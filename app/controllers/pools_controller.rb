class PoolsController < ApplicationController
  before_action :set_pool, only: [:show, :edit, :update, :destroy]
  before_action :confirm_admin_logged_in

  # GET /pools
  # GET /pools.json
  def index
    @pools = Pool.all.desc(:start_date, :created_at).page(params[:page]).per(10)
  end

  # GET /pools/1
  # GET /pools/1.json
  def show
  end

  # GET /pools/new
  def new
    @pool = Pool.new
  end

  # GET /pools/1/edit
  def edit
  end

  # POST /pools
  # POST /pools.json
  def create
    @pool = Pool.new(pool_params)
    respond_to do |format|
      if @pool.save
        format.html { redirect_to @pool, notice: 'Pool was successfully created.' }
        format.json { redirect_to pools_path(format: :json) }
      else
        format.html { render :new }
        format.json { render json: @pool.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pools/1
  # PATCH/PUT /pools/1.json
  def update
    respond_to do |format|
      if @pool.update(pool_params)
        format.html { redirect_to @pool, notice: 'Pool was successfully updated.' }
        format.json { render :show, status: :ok, location: @pool }
      else
        if @pool.errors.key?('intervals')
          @pool.intervals.each { |i| @pool.errors.add(i.id.to_s, i.errors) if i.errors.any? }
        end

        format.html { render :edit }
        format.json { render json: @pool.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pools/1
  # DELETE /pools/1.json
  def destroy
    respond_to do |format|
      if @pool.destroy
        format.html { redirect_to pools_url, notice: 'Pool was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { render json: @pool.errors, status: :unprocessable_entity }
        format.json { render json: @pool.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_pool
    @pool = Pool.find(params[:id])
    @pool.modified_by = @current_user
  end

  # Only allow a list of trusted parameters through.
  def pool_params
    params.require(:pool).permit(
      :name, :start_date, :amount, :daily_amount, :estimated_amount, :fixed_amount,
      intervals_attributes: [:id, :amount, :fixed]
    ).merge(modified_by: @current_user)
  end
end
