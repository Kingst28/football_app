class ResultsMastersController < ApplicationController

  # GET /results_masters
  # GET /results_masters.json
  def index
    @results_masters = ResultsMaster.all
  end

  # GET /results_masters/1
  # GET /results_masters/1.json
  def show
    @results_master = ResultsMaster.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @results_master }
    end
  end

  # GET /results_masters/new
  def new
    @results_master = ResultsMaster.new
  end

  # GET /results_masters/1/edit
  def edit
    @results_master = ResultsMaster.find(params[:id])
  end

  def admin_edit
    league_count = Player.distinct.count(:account_id)
    player_count = Player.count()
    player_set_count = player_count / league_count
    @results_masters = ResultsMaster.first(player_set_count)
    session[:my_previous_url] = URI(request.referer || '').path
  end

  def copy_results
    ActsAsTenant.without_tenant do
    @results_masters = ResultsMaster.all
    league_count = Player.count("DISTINCT account_id") 
    player_count = Player.count()
    player_set_count = player_count / league_count
    @results_master = ResultsMaster.first(player_set_count)
      for player in @results_master do
        player_name_array = Player.where(:id => player.player_id).pluck(:name)
        player_name = player_name_array[0]
        @duplicate_players = Player.where(:name => player_name).where.not(id: player.player_id)
        
        for duplicate_player in @duplicate_players do
          duplicate_player_id = duplicate_player.id
          results_master_player = ResultsMaster.where(:player_id => duplicate_player_id)
          results_master_player.update_all(:played => player.read_attribute(:played))
          results_master_player.update_all(:scored => player.read_attribute(:scored))
          results_master_player.update_all(:scorenum => player.read_attribute(:scorenum))
          results_master_player.update_all(:conceded => player.read_attribute(:conceded))
          results_master_player.update_all(:concedednum => player.read_attribute(:concedednum))
        end
      end
  end
end

def copy_results_to_teamsheets
  ActsAsTenant.without_tenant do
  @results_masters = ResultsMaster.all
    for player in @results_masters do    
        teamsheet_master_player = Teamsheet.where(:player_id => player.player_id)
        teamsheet_master_player.update_all(:played => player.read_attribute(:played))
        teamsheet_master_player.update_all(:scored => player.read_attribute(:scored))
        teamsheet_master_player.update_all(:scorenum => player.read_attribute(:scorenum))
        teamsheet_master_player.update_all(:conceded => player.read_attribute(:conceded))
        teamsheet_master_player.update_all(:concedednum => player.read_attribute(:concedednum))
    end
    redirect_to "/admin_index"
end
end

def edit_multiple
    @results_masters = ResultsMaster.find(params[:results_masters_ids])
end

def update_multiple
 ResultsMaster.update(params[:results_masters].keys, params[:results_masters].values)
end

  # POST /results_masters
  # POST /results_masters.json
  def create
    @results_master = ResultsMaster.new(results_master_params)

    respond_to do |format|
      if @results_master.save
        format.html { redirect_to @results_master, notice: 'Results master was successfully created.' }
        format.json { render :show, status: :created, location: @results_master }
      else
        format.html { render :new }
        format.json { render json: @results_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /results_masters/1
  # PATCH/PUT /results_masters/1.json
  def update
    @results_master = ResultsMaster.find(params[:id])

    respond_to do |format|
      if @results_master.update_attributes(params[:results_master].permit(:results_master_ids))
        format.html { redirect_to @results_master, notice: 'Product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @results_master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results_masters/1
  # DELETE /results_masters/1.json
  def destroy
    @results_master.destroy
    respond_to do |format|
      format.html { redirect_to results_masters_url, notice: 'Results master was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

    # Never trust parameters from the scary internet, only allow the white list through.
    def results_master_params
      params.require(:results_master).permit(:player_id, :played, :scored, :scorenum, :conceded, :concedednum)
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_results_master
      @results_masters = ResultsMaster.find(params[:id])
    end
end
