class PlayersController < ApplicationController
  before_action :require_user, only: [:index, :show, :new, :create, :edit, :update, :delete]
	def index
      @search = Player.search do 
      fulltext params[:search]
      end
      @players = @search.results
	end
    
  def show 
  		@players = Player.where(:teams_id => params[:teams_id])
  		@team = Team.where(:id => params[:teams_id])
  		@goalkeepers = @players.where(:position => 'Goalkeeper')
  		@defenders = @players.where(:position => 'Defender')
  		@midfielders = @players.where(:position => 'Midfielder')
  		@strikers = @players.where(:position => 'Striker')
	   @notifications_all = Notification.all
	end

 def new
      @player = Player.new
      @notifications_all = Notification.all
   end

   def player_params
      params.require(:player).permit(:name, :teams_id, :position, :playerteam, :account_id)
   end

   def create
      @account_ids = Account.distinct.pluck(:id)
      index = 0
      for account in @account_ids do
         @player = Player.new(player_params)
         team_name = Team.where(:id => player_params[:teams_id]).pluck(:name)
         club_ids = Team.where(:name => team_name[0]).pluck(:id)
         @player.update(:account_id => account, :teams_id => club_ids[index])
         index = index + 1
      end
      if !ResultsMaster.where(:name => player_params[:playerteam]).exists? then
         @results_master = ResultsMaster.new(:played => false, :scored => false, :conceded => false, :concedednum => 0, :scorenum => 0, :name => player_params[:playerteam], :league => 'Premier League')
         @results_master.save
      end
      if @player.save
          redirect_to action: "show", teams_id: @player.teams_id
      end
   end

    def edit
      @player = Player.find(params[:id])
    end

   def player_param
      params.require(:player).permit(:name, :teams_id, :position, :taken, :playerteam)
   end

   def update
      @player = Player.find(params[:id])
  
   if @player.update_attributes(player_param)
      redirect_to action: "show", teams_id: @player.teams_id
   end
 end

   def delete
      name = Player.find(params[:id]).name
      playerteam = Player.find(params[:id]).playerteam
      teams_id = Player.find(params[:id]).teams_id
      @all_players = Player.where(name: name)
      for player in @all_players do
         id = player.id
         @bid = Bid.where(player_id: player.id)
         if @bid.exists? then
            bidAmount = Bid.where(player_id: player.id).pluck(:amount)[0]
            currentBudget = User.find(Bid.where(player_id: player.id).pluck(:user_id)[0]).budget
            newBudget = currentBudget + bidAmount
            @user = User.find(Bid.where(player_id: player.id).pluck(:user_id)[0])
            @user.update_attribute(:budget, newBudget)
            @bidDelete = Bid.where(player_id: player.id).destroy_all
            @teamsheetDelete = Teamsheet.where(player_id: player.id).destroy_all
         end
         @results_masterDelete = ResultsMaster.where(name: playerteam).destroy_all
         @playerstatsDelete = PlayerStats.where(playerteam: playerteam).destroy_all
         @player = Player.find(player.id).destroy
      end
      redirect_to action: "show", teams_id: teams_id
   end
end
