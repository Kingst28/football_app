class PlayerstatsController < ApplicationController
  before_action :require_user
  before_action :set_playerstat, only: [:show, :edit, :update, :destroy]

  # GET /playerstats
  # GET /playerstats.json
  def index
    @playerstats = Playerstat.all
  end

  # GET /playerstats/1
  # GET /playerstats/1.json
  def show
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")     
  end

  # GET /playerstats/new
  def new
    @playerstat = Playerstat.new
  end

  # GET /playerstats/1/edit
  def edit
  end

  # POST /playerstats
  # POST /playerstats.json
  def create
    @playerstat = Playerstat.new(playerstat_params)

    respond_to do |format|
      if @playerstat.save
        format.html { redirect_to @playerstat, notice: 'Playerstat was successfully created.' }
        format.json { render :show, status: :created, location: @playerstat }
      else
        format.html { render :new }
        format.json { render json: @playerstat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /playerstats/1
  # PATCH/PUT /playerstats/1.json
  def update
    respond_to do |format|
      if @playerstat.update(playerstat_params)
        format.html { redirect_to @playerstat, notice: 'Playerstat was successfully updated.' }
        format.json { render :show, status: :ok, location: @playerstat }
      else
        format.html { render :edit }
        format.json { render json: @playerstat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playerstats/1
  # DELETE /playerstats/1.json
  def destroy
    @playerstat.destroy
    respond_to do |format|
      format.html { redirect_to playerstats_url, notice: 'Playerstat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playerstat
      @playerstat = Playerstat.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def playerstat_params
      params.require(:playerstat).permit(:player_id, :played, :scored, :scorenum, :conceded, :concedednum)
    end
end
