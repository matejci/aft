class HashtagsController < ApplicationController
  before_action :set_hashtag, only: [:show, :edit, :update, :destroy]

  before_action :confirm_user_logged_in, only: [:create, :update, :destroy] if Rails.env.development?
  before_action :confirm_user_logged_in if Rails.env.production?

  # GET /hashtags
  # GET /hashtags.json
  def index
    @hashtags = Hashtag.all
  end

  # GET /hashtags/1
  # GET /hashtags/1.json
  def show
  end

  # GET /hashtags/new
  def new
    @hashtag = Hashtag.new
  end

  # GET /hashtags/1/edit
  def edit
  end

  # POST /hashtags
  # POST /hashtags.json
  def create
    @hashtag = Hashtag.new(hashtag_params)
    @hashtag.created_by_id = @current_user._id

    respond_to do |format|
      if @hashtag.save
        format.html { redirect_to @hashtag, notice: 'Hashtag was successfully created.' }
        format.json { render :show, status: :created, location: @hashtag }
      else
        format.html { render :new }
        format.json { render json: @hashtag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /hashtags/1
  # PATCH/PUT /hashtags/1.json
  def update
    respond_to do |format|
      if @hashtag.update(hashtag_params)
        format.html { redirect_to @hashtag, notice: 'Hashtag was successfully updated.' }
        format.json { render :show, status: :ok, location: @hashtag }
      else
        format.html { render :edit }
        format.json { render json: @hashtag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hashtags/1
  # DELETE /hashtags/1.json
  def destroy
    @hashtag.destroy
    respond_to do |format|
      format.html { redirect_to hashtags_url, notice: 'Hashtag was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_hashtag
      @hashtag = Hashtag.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def hashtag_params
      params.require(:hashtag).permit(:name, :link, :status, :takeover, :created_by_id, :category_id)
    end
end
