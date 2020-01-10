class ResultsMastersController < ApplicationController
  before_action :authorize_admin
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

  def create_records
    ActsAsTenant.without_tenant do
    Player.find_each do |player|
    ResultsMaster.create(:player_id => player.id)
    end
    redirect_to '/admin_index'
  end
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
    @results_masters = ResultsMaster.all.joins(:player).order("name, position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'")
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
          results_master_player = ResultsMaster.where(:player_id => duplicate_player_id).pluck(:id)
          results_master_id = results_master_player[0]
          @results_master_player = ResultsMaster.find(results_master_id)
          @results_master_player.update(:played => player.read_attribute(:played))
          @results_master_player.update(:scored => player.read_attribute(:scored))
          @results_master_player.update(:scorenum => player.read_attribute(:scorenum))
          @results_master_player.update(:conceded => player.read_attribute(:conceded))
          @results_master_player.update(:concedednum => player.read_attribute(:concedednum))
        end
      end
    end
  end

  def copy_results_to_teamsheets
  ActsAsTenant.without_tenant do
  @results_masters = ResultsMaster.all
    for player in @results_masters do    
        teamsheet_id = Teamsheet.where(:player_id => player.player_id).pluck(:id)
        teamsheet_id_final = teamsheet_id[0]
        if Teamsheet.exists?(id: teamsheet_id_final) then
          teamsheet = Teamsheet.find(teamsheet_id[0])
          teamsheet.validate = true
          playerPlayed = convertValue(player.played)
          playerScored = convertValue(player.scored)
          playerConceded = convertValue(player.conceded)
          playerScoreNum = player.scorenum.to_s
          teamsheet.played_will_change!
          teamsheet.scored_will_change!
          teamsheet.scorenum_will_change!
          teamsheet.conceded_will_change!
          teamsheet.concedednum_will_change!
          teamsheet.save(:played => playerPlayed)
          teamsheet.save(:scored => playerScored)
          teamsheet.save(:scorenum => player.scorenum.to_s)
          teamsheet.save(:conceded => playerConceded)
          teamsheet.save(:concedednum => player.concedednum.to_s)
        end
    end
    redirect_to '/admin_index'
  end
  end

  def convertValue (playerValue)
    if playerValue == true then
      return 't'
    elsif playerValue == false then
      return 'f'  
  end
  end

  def edit_multiple
    @results_masters = ResultsMaster.find(params[:results_masters_ids])
  end

  def update_multiple
    ResultsMaster.update(params[:results_masters].keys, params[:results_masters].values)
  end

  def results_master_params
    params.require(:results_master).permit(:player_id, :played, :scored, :scorenum, :conceded, :concedednum)
  end

  # POST /results_masters
  # POST /results_masters.json
  # Comment
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

  def adminUser?
    current_user.access == "admin"
  end
  
  def authorize_admin 
    unless adminUser?
      flash[:error] = "unauthorized access"
      if require_admin then
      redirect_to '/admin_index'
      else
      redirect_to '/index' 
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_results_master
      @results_masters = ResultsMaster.find(params[:id])
    end
end