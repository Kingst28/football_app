class PlayersController < ApplicationController
	def index
		@players = Player.all
	end
    
    def show 
  		@players = Player.where(:teams_id => params[:teams_id])
  		@team = Team.where(:id => params[:teams_id])
  		@goalkeepers = @players.where(:position => 'Goalkeeper')
  		@defenders = @players.where(:position => 'Defender')
  		@midfielders = @players.where(:position => 'Midfielder')
  		@strikers = @players.where(:position => 'Striker')
	end
end
