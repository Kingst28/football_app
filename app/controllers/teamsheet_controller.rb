class TeamsheetController < ApplicationController
  before_action :authorize_admin, only: [:admin_edit]

   def index 
  	players = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => current_user.id).where(:active => ['true',true])
    @players = players
    playerList = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => current_user.id)
    @playerList = playerList
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
    @goalkeeper = []
    @defender = []
    @midfielder = []
    @striker = []
    @players.each do |p|
    
    if p.read_attribute(:position) == 'Goalkeeper' then
      @goalkeeper << p.player
    elsif p.read_attribute(:position) == 'Defender' then
      @defender << p.player
    elsif p.read_attribute(:position) == 'Midfielder' then
      @midfielder << p.player
    elsif p.read_attribute(:position) == 'Striker' then
      @striker << p.player
    end
    end
   end

   def index2 
    all_teams = Teamsheet.all.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc")
    @teamPlayers = all_teams.joins(:user).order("first_name", "last_name").group_by(&:user_id)
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
   end

   def new 
   	@teamsheet = Teamsheet.new
   end

   def show 
   end

   def edit
     @teamsheet = Teamsheet.find(params[:id])
     session[:my_previous_url] = URI(request.referer || '').path
   end

   def admin_edit
     @teamsheets = Teamsheet.all.order(:user_id)
     session[:my_previous_url] = URI(request.referer || '').path
   end

   def edit_multiple
      @teamsheets = Teamsheet.find(params[:teamsheet_ids])
   end

  def update_multiple
   Teamsheet.update(params[:teamsheets].keys, params[:teamsheets].values)
  end

   def teamsheet_params
      params.require(:teamsheet).permit(:user_id, :player_id, :amount, :active, :played, :scored, :scorenum, :conceded, :concedednum, :priority)
   end

   def calculate_score 
      @users = User.all
      for u in @users do
      total_scorenum = 0
      total_connum = 0
      defenderCount = 0
      scorenum = 0

      @teamsheet_scorers = Teamsheet.where(:user_id => u.id).where(:active => true)
      for p in @teamsheet_scorers do
      if(p.read_attribute(:scored) == true) then
      scorenum = p.read_attribute(:scorenum).to_i
      total_scorenum = total_scorenum + scorenum
      else
      end
      end

      @teamsheet_conceders = Teamsheet.where(:user_id => u.id).where(:active => true)
      for p in @teamsheet_conceders do 
        if(p.read_attribute(:conceded) == true) then
        concedednum = p.read_attribute(:concedednum) 
        total_connum = total_connum + concedednum 
      else
      end
      end

      for p in @teamsheet_conceders do
      if p.player.position == 'Defender' || p.player.position == 'Goalkeeper' && p.read_attribute(:played) == true then
         defenderCount = defenderCount + 1
      end
    end
    if defenderCount == 0 then
    else
    con_score1 = 5 - defenderCount
    con_score2 = total_connum / defenderCount
    final_con_score = con_score1 + con_score2
    con_score = final_con_score * -1
    final_score = total_scorenum + con_score
    @result_new = Result.new(:user_id => u.id, :score => final_score)
    @result_new.save
    end
    end
   end

  def update
    @teamsheet = Teamsheet.find(params[:id])
    if @teamsheet.update_attributes(teamsheet_params)
        redirect_to '/teamsheet/index' 
    else
      if @teamsheet.errors.any?
         @teamsheet.errors.full_messages.each do |message|
         flash[:danger] = message 
       end 
      end 
    redirect_to session.delete(:my_previous_url)
  end
  end

   def delete 
   	  @teamsheetDelete = Teamsheet.find(params[:id]).destroy
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
end
