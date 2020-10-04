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
   end

   def player_params
      params.require(:player).permit(:name, :teams_id, :position, :playerteam, :account_id)
   end

   def create
      @account_ids = Account.distinct.pluck(:id)
      for account in @account_ids do
         @player = Player.new(player_params)
         @player.update(:account_id => account)
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
      @player = Player.find(params[:id]).destroy
      redirect_to action: "show", teams_id: @player.teams_id
   end
end
