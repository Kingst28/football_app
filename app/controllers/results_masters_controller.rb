class ResultsMastersController < ApplicationController
  #before_action :require_user
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
  
  def admin_edit
    ActsAsTenant.without_tenant do
    @notifications_all = Notification.all
    @results_masters = ResultsMaster.where(:name => Teamsheet.select(:name).map(&:name)).order(:team)
    session[:my_previous_url] = URI(request.referer || '').path
    end
  end
  
  # set name field to be name and team to match on so likelihood of same name and same team are slim. 
  # set default 0 values for all teamsheet attributes such as scorenum
  # stop the creation of results_masters records for all player sets across the leagues only one is required if the update all SQL statement works!
  # for adding new leagues, we need to have results_masters have all player name + team in place for each league Prem + Bundesliga.
  def copy_results_to_teamsheets
  ActsAsTenant.without_tenant do
  @results_masters = ResultsMaster.all
  @notifications_all = Notification.all
    for player in @results_masters do   
        player_name_array = Player.where(:playerteam => player.name).pluck(:playerteam)
        player_name = player_name_array[0]
        player_played = player.read_attribute(:played)
        player_scored = player.read_attribute(:scored)
        player_scorenum = player.read_attribute(:scorenum)
        player_conceded = player.read_attribute(:conceded)
        player_concedednum = player.read_attribute(:concedednum)
        teamsheet_name = Teamsheet.where(:name => player.name).pluck(:name)
        teamsheet_name_final = teamsheet_name[0]
        if Teamsheet.exists?(name: teamsheet_name_final) then
        Teamsheet.where(:name => player_name).update_all(
          "played = #{player_played}, 
          scored = #{player_scored}, 
          scorenum = #{player_scorenum}, 
          conceded = #{player_conceded}, 
          concedednum = #{player_concedednum}")
        end
        @teamsheets = Teamsheet.all.joins(:player).order("name, position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'")
      end
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
    @results_masters = ResultsMaster.where(:id => params[:results_masters_ids]).order(:team)
    @notifications_all = Notification.all
  end

  def update_multiple
    ResultsMaster.update(params[:results_masters].keys, params[:results_masters].values)
    @notifications_all = Notification.all
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