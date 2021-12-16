class UsernamesController < ApplicationController
  before_action :set_username, only: [:show, :edit, :update, :destroy]
  before_action :confirm_admin_logged_in

  def index
    @usernames = Username.all.order_by([:created_at, :desc]).page(params[:page]).per(params[:limit])
  end

  def show
  end

  def new
    @username = Username.new
  end

  def edit
  end

  def upload
    Username.import(params[:username][:file])

    @usernames = Username.all.desc(:created_at).page(params[:page]).per(params[:limit])
    render :index, status: :created
  end

  def create
    @username = Username.new(username_params)

    respond_to do |format|
      if @username.save
        @usernames = Username.all.desc(:created_at).page(params[:page]).per(params[:limit])

        format.json { render :index, status: :created }
      else
        format.html { render :new }
        format.json { render json: @username.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @username.update(username_params)
        format.html { redirect_to @username, notice: 'Username was successfully updated.' }
        format.json { render :show, status: :ok, location: @username }
      else
        format.html { render :edit }
        format.json { render json: @username.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @username.destroy
    respond_to do |format|
      format.html { redirect_to usernames_url, notice: 'Username was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def claim
    if @username = Username.manage.find(params[:id])
      if @username.claim!(user_params)
        head :ok
      else
        render json: username_errors, status: :unprocessable_entity
      end
    else
      render json: { base: 'No managed account found' }, status: :not_found
    end
  end

  def manage
    @username = Username.manage_user(username_params)

    if @username.errors.any?
      render json: @username.errors, status: :unprocessable_entity
    else
      render 'manage_user.json'
    end
  end

  def make_searchable
    if %w(true false).include?(params[:searchable])
      if @username = Username.manage.find(params[:id])
        @username.searchable_user!(params[:searchable] == 'true')
      else
        render json: { base: 'No managed account found' }, status: :not_found
      end
    else
      render json: { base: 'params[:searchable] should be set to true or false' },
        status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_username
    @username = Username.find(params[:id])
  end

  def username_errors
    @username.errors.merge!(@username.user.errors)
    @username.errors
  end

  # Only allow a list of trusted parameters through.
  def username_params
    params.require(:username).permit(:alias, :email, :file, :name, :status, :type, :user_id)
  end

  def user_params
    params.require(:username).permit(user_attributes: [:birthdate, :display_name, :password])
  end
end
