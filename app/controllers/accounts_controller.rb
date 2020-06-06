class AccountsController < ApplicationController
  require 'csv'
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)
    @account.save
    Matchday.create(:matchday_number => 0, :haflag => 'Home', :account_id => @account.read_attribute(:id))
    timer_start = Time.now
    timer_end = timer_start + 172800
    date_end = timer_end.strftime("%b %d, %Y %T") # => "Feb 10, 2020 12:29:56"
    Timer.create(:date => date_end, :account_id => @account.read_attribute(:id))
    
    create_teams(@account.read_attribute(:id))
    create_players(@account.read_attribute(:id))
    create_records(@account.read_attribute(:id))
    create_player_stats(@account.read_attribute(:id))


     respond_to do |format|
      if @account.save
        format.html { redirect_to @account, notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_teams(account_id)
    rows_array = CSV.read('lib/tasks/teams.csv')
    
    range_array = (0..19).to_a
    desired_indices = range_array.sort # these are rows you would like to modify
    teams_count = Team.maximum(:id)
    if Team.exists? then 
    else
      teams_count = 0
    end
    rows_array.each.with_index(desired_indices[0]) do |row, index| 
    if desired_indices.include?(index)
      # modify over here
    teams_count = teams_count + 1
    rows_array[index][0] = teams_count
    rows_array[index][2] = account_id
  end
end
# now update the file
CSV.open('lib/tasks/teams.csv', 'wb') { |csv| rows_array.each{|row| csv << row}}

CSV.foreach('lib/tasks/teams.csv') do |row|
  Team.create!({
    :id => row[0],
    :name => row[1],        
    :account_id => row[2]
  })
  end
end

def create_players(account_id)
  players_array = CSV.read('lib/tasks/players.csv')
    
  range_array = (0..722).to_a
  desired_indices = range_array.sort # these are rows you would like to modify
  players_array.each.with_index(desired_indices[0]) do |row, index| 
  if desired_indices.include?(index)
  # modify over here
  @playerteam = players_array[index][3].partition('- ').last
  @player_team_id = Team.where(:name => @playerteam).where(:account_id => account_id).pluck(:id)[0]
  players_array[index][2] = @player_team_id
  players_array[index][4] = account_id
  end
end
# now update the file
CSV.open('lib/tasks/players.csv', 'wb') { |csv| players_array.each{|row| csv << row}}

CSV.foreach('lib/tasks/players.csv') do |row|
  Player.create!({
    :name => row[0],
    :position => row[1],
    :teams_id => row[2],
    :playerteam => row[3],
    :account_id => row[4]        
  })
  puts "Row added!"
end
end

# add name field to ResultsMaster model and then I can test if update all on name method is faster than updating each individual column in copy results. 
def create_records (account_id)
  ActsAsTenant.without_tenant do
  account_id = params[:id]
  @players = Player.where(:account_id => account_id)
  Player.find_each do |player|
  ResultsMaster.create(:player_id => player.id, :name => player.name)
  end
end
end

# add name field to ResultsMaster model and then I can test if update all on name method is faster than updating each individual column in copy results. 
def create_player_stats (account_id)
  ActsAsTenant.without_tenant do
  account_id = params[:id]
  @players = Player.where(:account_id => account_id)
  Player.find_each do |player|
  Playerstat.create(:player_id => player.id, :played => false, :scored => false, :scorenum => 0, :conceded => false, :concedednum => 0, :playerteam => player.playerteam, :account_id => account_id)    
  end
end
end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:name)
    end
end
