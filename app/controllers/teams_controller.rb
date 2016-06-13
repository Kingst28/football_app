class TeamsController < ApplicationController
    before_action :require_user, only: [:index, :show, :new, :create, :edit, :update, :delete]
	def index
		@teams = Team.all
	end

	def new
      @team = Team.new
   end

   def team_params
      params.require(:team).permit(:name)
   end

   def create
      @team = Team.new(team_params)

      if @team.save
          redirect_to action: "index"
      end
   end

    def edit
      @team = Team.find(params[:id])
    end

   def team_param
      params.require(:team).permit(:name)
   end

   def update
      @team = Team.find(params[:id])
  
   if @team.update_attributes(team_param)
      redirect_to action: "index"
   end
 end

   def delete
      @team = Team.find(params[:id]).destroy
      redirect_to action: "index"
   end
end
