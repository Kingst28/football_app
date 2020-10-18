class TeamsheetController < ApplicationController
  #before_action :require_user
  before_action :authorize_admin, only: [:admin_edit]

   def index 
  	players = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => current_user.id).where(:active => ['true',true])
    @players = players
    playerList = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => current_user.id)
    @playerList = playerList
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
    
    @current_matchday = Matchday.where(:account_id => current_user.account_id)
    @fixture = Fixture.where(:matchday => @current_matchday.first.matchday_number).where(:haflag => @current_matchday.first.haflag).where(:account_id => @current_matchday.first.account_id)

    gk_def_played = Teamsheet.where(:user_id => current_user.id).where(:played => true).joins(:player).where("position = 'Goalkeeper' OR position = 'Defender'").count
    total_scored = Teamsheet.where(:user_id => current_user.id).where(:active => true).sum(:scorenum).to_s.tr('""','').tr('[]','').to_i
    total_conceded = Teamsheet.where(:user_id => current_user.id).where(:active => true).sum(:concedednum).to_s.tr('""','').tr('[]','').to_i

    def_score = gk_def_played / 5
    con_score = def_score + total_conceded
    @final_score = con_score + total_scored
    
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
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
    teamsheet = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => params[:user_id]).where(:active => ['true',true])
    @teamsheet = teamsheet
    playerList = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => params[:user_id])
    @playerList = playerList
    user_matches = LeagueTable.where(:team => User.where(:id => params[:user_id]).pluck(:teamname)).pluck(:played).to_s.tr('""','').tr('[]','')
    user_wins = LeagueTable.where(:team => User.where(:id => params[:user_id]).pluck(:teamname)).pluck(:won).to_s.tr('""','').tr('[]','')
    user_points = LeagueTable.where(:team => User.where(:id => params[:user_id]).pluck(:teamname)).pluck(:points).to_s.tr('""','').tr('[]','')
    user_goals_scored = LeagueTable.where(:team => User.where(:id => params[:user_id]).pluck(:teamname)).pluck(:for).to_s.tr('""','').tr('[]','')
    user_goals_conceded = LeagueTable.where(:team => User.where(:id => params[:user_id]).pluck(:teamname)).pluck(:against).to_s.tr('""','').tr('[]','')
    @win_average = user_wins.to_d / user_matches.to_d  
    @points_average = user_points.to_d / user_matches.to_d
    @goals_average = user_goals_scored.to_d / user_matches.to_d  
    @conceded_average = user_goals_conceded.to_d / user_matches.to_d  

    gk_def_played = Teamsheet.where(:user_id => params[:user_id]).where(:played => true).joins(:player).where("position = 'Goalkeeper' OR position = 'Defender'").count
    total_scored = Teamsheet.where(:user_id => params[:user_id]).where(:active => true).sum(:scorenum).to_s.tr('""','').tr('[]','').to_i
    total_conceded = Teamsheet.where(:user_id => params[:user_id]).where(:active => true).sum(:concedednum).to_s.tr('""','').tr('[]','').to_i

    def_score = gk_def_played / 5
    con_score = def_score + total_conceded
    @final_score = con_score + total_scored
   end

   def stats
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")     
    @users = User.all
   end

   def edit
     @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")     
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
      params.require(:teamsheet).permit(:user_id, :player_id, :amount, :active, :played, :scored, :scorenum, :conceded, :concedednum, :priority, :account_id)
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
end
