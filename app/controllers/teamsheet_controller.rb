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

    @latest_results = Fixture.where('hteam=? OR ateam=?', current_user.id.to_s, current_user.id.to_s).where(:haflag => Matchday.where(:account_id => current_user.account_id).first.haflag).where.not(:finalscore => '').order(:matchday).last(5)

    @results = [] 

    for result in @latest_results do
      if result.haflag == "Home" && result.hteam == current_user.id.to_s then
        finalscore = result.finalscore
        if finalscore[0].to_i > finalscore[1].to_i then
          @results << "W"
        elsif finalscore[0].to_i < finalscore[1].to_i then
          @results << "L"
        elsif finalscore[0].to_i == finalscore[1].to_i then
          @results << "D"
        end

      elsif result.haflag == "Home" && result.ateam == current_user.id.to_s then
        finalscore = result.finalscore
        if finalscore[1].to_i > finalscore[0].to_i then
          @results << "W"
        elsif finalscore[1].to_i < finalscore[0].to_i then
          @results << "L"
        elsif finalscore[1].to_i == finalscore[0].to_i then
          @results << "D"
        end

      elsif result.haflag == "Away" && result.ateam == current_user.id.to_s then
        finalscore = result.finalscore
        if finalscore[1].to_i > finalscore[0].to_i then
          @results << "W"
        elsif finalscore[1].to_i < finalscore[0].to_i then
          @results << "L"
        elsif finalscore[1].to_i == finalscore[0].to_i then
          @results << "D"
        end

      elsif result.haflag == "Away" && result.hteam == current_user.id.to_s then
        finalscore = result.finalscore
        if finalscore[0].to_i > finalscore[1].to_i then
          @results << "W"
        elsif finalscore[0].to_i < finalscore[1].to_i then
          @results << "L"
        elsif finalscore[0].to_i == finalscore[1].to_i then
          @results << "D"
        end
      end
    end
    

    #defenderCount = Teamsheet.where(:user_id => current_user.id).where(:played => true).joins(:player).where("position = 'Goalkeeper' OR position = 'Defender'").count
    #total_scorenum = Teamsheet.where(:user_id => current_user.id).where(:active => true).sum(:scorenum).to_s.tr('""','').tr('[]','').to_i
    #total_connum = Teamsheet.where(:user_id => current_user.id).where(:active => true).sum(:concedednum).to_s.tr('""','').tr('[]','').to_i
    #@final_score = []
    
    #if defenderCount = 0 then 
    #else
      #con_score1 = 5 - defenderCount
      #con_score2 = total_connum / defenderCount
      #final_con_score = con_score1 + con_score2
      #con_score = final_con_score * -1
      #@final_score << total_scorenum + con_score
    #end
    
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

    #defenderCount = Teamsheet.where(:user_id => params[:user_id]).where(:played => true).joins(:player).where("position = 'Goalkeeper' OR position = 'Defender'").count
    #total_scorenum = Teamsheet.where(:user_id => params[:user_id]).where(:active => true).sum(:scorenum).to_s.tr('""','').tr('[]','').to_i
    #total_connum = Teamsheet.where(:user_id => params[:user_id]).where(:active => true).sum(:concedednum).to_s.tr('""','').tr('[]','').to_i

    #con_score1 = 5 - defenderCount
    #con_score2 = total_connum / defenderCount
    #final_con_score = con_score1 + con_score2
    #con_score = final_con_score * -1
    #@final_score = total_scorenum + con_score
  
   end

   def stats
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")     
    @users = User.all
   end

   def edit
     @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")     
     @teamsheet = Teamsheet.find(params[:id])
     session[:my_previous_url] = URI(request.referer || '').path
     @squad = Teamsheet.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").order("active desc").order("priority asc").where(:user_id => current_user.id)
   end

   def admin_edit
     @teamsheets = Teamsheet.all.order(:user_id)
     session[:my_previous_url] = URI(request.referer || '').path
   end

   def edit_multiple
      @teamsheets = Teamsheet.find(params[:teamsheet_ids])
   end

  def update_multiple
   goalkeeperActiveCount = 0
   goalkeeperInactiveCount = 0
   defenderActiveCount = 0
   defenderInactiveCount = 0
   midfielderActiveCount = 0
   midfielderInactiveCount = 0
   strikerActiveCount = 0
   strikerInactiveCount = 0
   
   gkDoubleOne = 0
   defDoubleOne = 0
   defDoubleTwo = 0
   midDoubleOne = 0
   midDoubleTwo = 0
   stkDoubleOne = 0
   stkDoubleTwo = 0 

   gkActivePri = 0
   defActivePri = 0
   midActivePri = 0
   stkActivePri = 0

   ids = params[:teamsheets]
   for id in ids do
    player_id = id.last[:player_id].to_i
    position = Player.find(player_id).position
    active = id.last[:active].to_i
    priority = id.last[:priority].to_i
    
    #check if users have the right amount of pri players/active
    if (position == 'Goalkeeper' && active == 0) && priority == 1 then 
      goalkeeperInactiveCount = goalkeeperInactiveCount + 1
    elsif position == 'Goalkeeper' && active == 1 then
      goalkeeperActiveCount = goalkeeperActiveCount + 1
    elsif (position == 'Defender' && active == 0) && (priority == 1 || priority == 2) then
      defenderInactiveCount = defenderInactiveCount + 1
    elsif position == 'Defender' && active == 1 then
      defenderActiveCount = defenderActiveCount + 1
    elsif (position == 'Midfielder' && active == 0) && (priority == 1 || priority == 2) then
      midfielderInactiveCount = midfielderInactiveCount + 1
    elsif position == 'Midfielder' && active == 1 then
      midfielderActiveCount = midfielderActiveCount + 1  
    elsif (position == 'Striker' && active == 0) && (priority == 1 || priority == 2) then
      strikerInactiveCount = strikerInactiveCount + 1
    elsif position == 'Striker' && active == 1 then
      strikerActiveCount = strikerActiveCount + 1
    end
   
   #check if users have 2 pri 1s or 2 pri 2s in any position.
   if (position == 'Goalkeeper' && active == 0) && priority == 1 then 
      gkDoubleOne = gkDoubleOne + 1
   elsif (position == 'Defender' && active == 0) && priority == 1 then
    defDoubleOne = defDoubleOne + 1
   elsif (position == 'Defender' && active == 0) && priority == 2 then
    defDoubleTwo = defDoubleTwo + 1
   elsif (position == 'Midfielder' && active == 0) && priority == 1 then
      midDoubleOne = midDoubleOne + 1
   elsif (position == 'Midfielder' && active == 0) && priority == 2 then
      midDoubleTwo = midDoubleTwo + 1
   elsif (position == 'Striker' && active == 0) && priority == 1 then
      stkDoubleOne = stkDoubleOne + 1
   elsif (position == 'Striker' && active == 0) && priority == 2 then
      stkDoubleTwo = stkDoubleTwo + 1
   end
   
   #check if users have active priority players
   if (position == 'Goalkeeper' && active == 1) && priority == 1 then 
    gkActivePri = gkActivePri + 1
   elsif (position == 'Defender' && active == 1) && (priority == 1 || priority == 2) then
    defActivePri = defActivePri + 1
   elsif (position == 'Midfielder' && active == 1) && (priority == 1 || priority == 2) then
    midActivePri = midActivePri + 1
   elsif (position == 'Striker' && active == 1) && (priority == 1 || priority == 2) then
    stkActivePri = stkActivePri + 1
   end
   end
  
   if goalkeeperActiveCount == 1 && goalkeeperInactiveCount == 1 && gkDoubleOne == 1 && gkActivePri == 0 && defenderActiveCount == 4 && defenderInactiveCount == 2 && defDoubleOne == 1 && defDoubleTwo == 1 && defActivePri == 0 && midfielderActiveCount == 4 && midfielderInactiveCount == 2 && midDoubleOne == 1 && midDoubleTwo == 1 && midActivePri == 0 && strikerActiveCount == 2 && strikerInactiveCount == 2 && stkDoubleOne == 1 && stkDoubleTwo == 1 && stkActivePri == 0 then
    Teamsheet.update(params[:teamsheets].permit!.keys, params[:teamsheets].permit!.values)
    flash[:success] = "Your squad changes are valid - GK active #{goalkeeperActiveCount}/1 sub #{goalkeeperInactiveCount}/1, DEF active #{defenderActiveCount}/4 subs #{defenderInactiveCount}/2, MID active #{midfielderActiveCount}/4 subs #{midfielderInactiveCount}/2, STR active #{strikerActiveCount}/2 subs #{strikerInactiveCount}/2"
    redirect_to '/teamsheet/index'
   else
    flash[:danger] = "Your squad changes are invalid - GK active #{goalkeeperActiveCount}/1 sub #{goalkeeperInactiveCount}/1, DEF active #{defenderActiveCount}/4 subs #{defenderInactiveCount}/2, MID active #{midfielderActiveCount}/4 subs #{midfielderInactiveCount}/2, STR active #{strikerActiveCount}/2 subs #{strikerInactiveCount}/2 "
    redirect_to(:back)
   end
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
