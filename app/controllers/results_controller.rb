class ResultsController < ApplicationController
  #before_action :require_user
  before_action :set_result, only: [:show, :edit, :update, :destroy]

  # GET /results
  # GET /results.json
  def index
    @results = Result.all
  end

  # GET /results/1
  # GET /results/1.json
  def show
  end

  # GET /results/new
  def new
    @result = Result.new
  end

  # GET /results/1/edit
  def edit
  end

  # POST /results
  # POST /results.json
  def create
    @result = Result.new(result_params)

    respond_to do |format|
      if @result.save
        format.html { redirect_to @result, notice: 'Result was successfully created.' }
        format.json { render :show, status: :created, location: @result }
      else
        format.html { render :new }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /results/1
  # PATCH/PUT /results/1.json
  def update
    respond_to do |format|
      if @result.update(result_params)
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { render :show, status: :ok, location: @result }
      else
        format.html { render :edit }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

def fixture_results
      @accounts = Account.all
      for account in @accounts do
      @users = User.where(:account_id => account.account_id)
      for u in @users do
      total_scorenum = 0
      total_connum = 0
      defenderCount = 0
      scorenum = 0
      playedCount = 0
      goalkeepers = 0
      defenders = 0
      midfielders = 0
      strikers = 0
      goalkeeperSubCount = 0
      defenderSubCount = 0
      midSubCount = 0
      strikerSubCount = 0

      @teamsheet_players = Teamsheet.where(:user_id => u.id).where(:active => true)
      @teamsheet_players_played = @teamsheet_players.where(:played => true)

      playedCount = @teamsheet_players_played.length

      if playedCount != 11 then
         for p in @teamsheet_players_played do 
            if p.player.position == 'Goalkeeper' then
              goalkeepers = goalkeepers + 1 
            elsif p.player.position == 'Defender' then
              defenders  = defenders + 1
            elsif p.player.position == 'Midfielder' then
              midfielders = midfielders + 1
            elsif p.player.position == 'Striker' then
              strikers = strikers + 1 
            end
          end
        end

      if playedCount == 11 then
         for p in @teamsheet_players_played do 
            if p.player.position == 'Goalkeeper' then
              goalkeepers = goalkeepers + 1 
            elsif p.player.position == 'Defender' then
              defenders  = defenders + 1
            elsif p.player.position == 'Midfielder' then
              midfielders = midfielders + 1
            elsif p.player.position == 'Striker' then
              strikers = strikers + 1 
            end
          end
        end

      goalkeeperSubCount = getGoalkeeperSubCount(goalkeepers, u)
      defenderSubCount = getDefenderSubCount(defenders,u)
      midSubCount = getMidSubCount(midfielders,u)
      strikerSubCount = getStrikerSubCount(strikers,u)      

      subGoalkeepers(goalkeeperSubCount,u)
      subDefenders(defenderSubCount,u)
      subMidfielders(midSubCount,u)
      subStrikers(strikerSubCount,u)

      @teamsheet_scorers = Teamsheet.where(:user_id => u.id).where(:active => [true, 'true']).where(:played => [true,'true'])
      for p in @teamsheet_scorers do
        if (p.read_attribute(:scored) == true) then
          scorenum = p.read_attribute(:scorenum).to_i
          total_scorenum = total_scorenum + scorenum
        else
      end
      end

      @teamsheet_conceders = Teamsheet.where(:user_id => u.id).where(:active => [true, 'true']).where(:played => [true,'true'])
      for p in @teamsheet_conceders do 
        if(p.read_attribute(:conceded) == true && p.player.position == "Goalkeeper") then
          concedednum = p.read_attribute(:concedednum).to_i 
          total_connum = total_connum + concedednum 
        elsif(p.read_attribute(:conceded) == true && p.player.position == "Defender") then
          concedednum = p.read_attribute(:concedednum).to_i 
          total_connum = total_connum + concedednum 
      end
      end

      for p in @teamsheet_conceders do
      if p.player.position == 'Defender' && p.read_attribute(:active) == true && p.read_attribute(:played) == true  then
        defenderCount += 1
      elsif p.player.position == 'Goalkeeper' && p.read_attribute(:active) == true && p.read_attribute(:played) == true then
        defenderCount += 1
      end
    end

    if defenderCount == 0 then
      con_score = 5 
      con_score = con_score * -1
      final_score = total_scorenum + con_score 
      @result_new = Result.new(:user_id => u.id, :score => final_score)
      @result_new.save
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
    
  matchday_id = Matchday.find(Matchday.where(:account_id => u.account_id)).read_attribute(:id)
  @matchday = Matchday.find(matchday_id)
  matchday_number = @matchday.read_attribute(:matchday_number)
  matchday_count = @matchday.read_attribute(:matchday_count)
  matchday_haflag = @matchday.read_attribute(:haflag)
 
 if matchday_haflag == 'Home' && matchday_number <= matchday_count then
    @fixtures = Fixture.where(:matchday => matchday_number).where(:haflag => 'Home')
 elsif 
    matchday_haflag == 'Away' && matchday_number <= matchday_count then
    @fixtures = Fixture.where(:matchday => matchday_number).where(:haflag => 'Away')
  else
    if matchday_haflag = 'Home' then
       matchday_id = Matchday.find(Matchday.where(:account_id => u.account_id)).read_attribute(:id)
       @matchday = Matchday.find(matchday_id)
       @matchday.update(:matchday_number => 0)
       @matchday.update(:haflag => 'Away'.to_s)
       @fixtures = Fixture.where(:matchday => 0).where(:haflag => 'Away')
       @matchday.update(:matchday_number => 0 + 1)
    else
      matchday_id = Matchday.find(Matchday.where(:account_id => u.account_id)).read_attribute(:id)
      @matchday = Matchday.find(matchday_id)
      @matchday.update(:matchday_number => 0)
      @matchday.update(:haflag => 'Home')
      @fixtures = Fixture.where(:matchday => 0).where(:haflag => 'Home')
      @matchday.update(:matchday_number => 0 + 1)
    end
  end
    
    for f in @fixtures do
      fuser1 = f.read_attribute(:hteam).to_i
      fuser2 = f.read_attribute(:ateam).to_i
      result1 = Result.find_by_user_id(fuser1).read_attribute(:score)
      result2 = Result.find_by_user_id(fuser2).read_attribute(:score)
      final_score = ""
      
      if result1 >= 0 && result2 >= 0 then
        final_score = result1.to_s + result2.to_s 
        f.update(:finalscore => final_score)
      elsif
        while result1 < 0 || result2 < 0 do
          result1 +=1
          result2 +=1
          final_score = result1.to_s + result2.to_s 
          f.update(:finalscore => final_score)
      end
    end
 end
updateLeagueTable()
ActiveRecord::Base.connection.execute("update teamsheets set active = 't' where priority IS NULL;")
ActiveRecord::Base.connection.execute("update teamsheets set active = 'f' where priority IS NOT NULL;")
end
end

def getGoalkeeperSubCount (goalkeepers, u)
    if goalkeepers != 1 then
        @all_players = Teamsheet.where(:user_id => u.id).where(:active => true)
        @false_played_players = @all_players.where(:played => false)
        goalkeeperSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Goalkeeper' then
             goalkeeperSubCount = goalkeeperSubCount + 1
             p.validate = true
             p.update(:active => false)
           end
         end
      end
      return goalkeeperSubCount
    end

def getDefenderSubCount (defenders,u) 
 if defenders != 4 then
        @all_players = Teamsheet.where(:user_id => u.id).where(:active => true)
        @false_played_players = @all_players.where(:played => false)
        defenderSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Defender' then
             defenderSubCount += 1
             p.validate = true
             p.update(:active => false)
           end
        end
      end
      return defenderSubCount
    end
 
def getMidSubCount (midfielders,u)
 if midfielders != 4 then
        @all_players = Teamsheet.where(:user_id => u.id).where(:active => true)
        @false_played_players = @all_players.where(:played => false)
        midSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Midfielder' then
             midSubCount = midSubCount + 1
             p.validate = true
             p.update(:active => false)
           end
        end
      end
      return midSubCount
    end

def getStrikerSubCount (strikers,u)
  if strikers != 2 then
      @all_players = Teamsheet.where(:user_id => u.id).where(:active => true)
      @false_played_players = @all_players.where(:played => false)
      strikerSubCount = 0
      for p in @false_played_players do
        if p.player.position == 'Striker' then
            strikerSubCount = strikerSubCount + 1
            p.validate = true
            p.update(:active => false)
          end
        end
    end
    return strikerSubCount
  end

def subGoalkeepers (goalkeeperSubCount,u)
     if goalkeeperSubCount == 1 then 
        @all_players2 = Teamsheet.where(:user_id => u.id)
        @priority_players = @all_players2.where(:priority => 1)
        for p in @priority_players do
          if p.player.position == 'Goalkeeper' && p.read_attribute(:played) == true then
             p.validate = true
             p.update(:active => true)
          elsif p.player.position == 'Goalkeeper' && p.read_attribute(:played) == false then
            total_connum = 0
            total_connum = total_connum + 1
        end
      end
  end
end

def subDefenders (defenderSubCount,u)
  if defenderSubCount == 1 then 
        @all_players4 = Teamsheet.where(:user_id => u.id)
        @priority_players2 = @all_players4.where(:priority => '1')
        for p in @priority_players2 do 
          if p.player.position == 'Defender' && p.read_attribute(:played) == true then
             p.validate = true
             p.update(:active => true) 
             @priority_players3 = @all_players4.where(:priority => '2')
             for p in @priority_players3 do 
             if p.player.position == 'Defender' then
                p.validate = true
                p.update(:played => nil)
             end
             end
          else 
            @priority_players3 = @all_players4.where(:priority => '2')
            for p in @priority_players3 do
              if p.player.position == 'Defender' && p.read_attribute(:played) == true then
                p.validate = true
                p.update(:active => true)
              end
            end
         end
      end
    
    elsif defenderSubCount == 2 then 
      @all_players7 = Teamsheet.where(:user_id => u.id)
      @all_priority_players = @all_players7.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players do
       if p.player.position == 'Defender' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
       end
      end
    
    elsif defenderSubCount == 3 then 
      @all_players7 = Teamsheet.where(:user_id => u.id)
      @all_priority_players = @all_players7.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players do
       if p.player.position == 'Defender' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
       end
      end
    
    elsif defenderSubCount == 4 then 
      @all_players8 = Teamsheet.where(:user_id => u.id)
      @all_priority_players = @all_players8.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players do
       if p.player.position == 'Defender' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
        end
      end
   end
end

def subMidfielders (midSubCount,u)
  if midSubCount == 1 then 
    @all_players4 = Teamsheet.where(:user_id => u.id)
    @priority_players2 = @all_players4.where(:priority => '1')
    for p in @priority_players2 do
      if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true) 
         @priority_players3 = @all_players4.where(:priority => '2')
         for p in @priority_players3 do 
          if p.player.position == 'Midfielder' then
            p.validate = true
            p.update(:played => nil)
          end
         end
      else 
        @priority_players3 = @all_players4.where(:priority => '2')
        for p in @priority_players3 do
          if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
            p.validate = true
            p.update(:active => true)
          end
        end
     end
  end
    
    elsif midSubCount == 2 then 
        @all_players8 = Teamsheet.where(:user_id => u.id)
        @all_priority_players1 = @all_players8.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players1 do
       if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
       end
      end
   
   elsif midSubCount == 3 then 
        @all_players8 = Teamsheet.where(:user_id => u.id)
        @all_priority_players1 = @all_players8.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players1 do
       if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
        end
      end

   elsif midSubCount == 4 then 
        @all_players9 = Teamsheet.where(:user_id => u.id)
        @all_priority_players1 = @all_players9.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players1 do
       if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
       end
      end
    end
  end

def subStrikers(strikerSubCount,u)
  if strikerSubCount == 1 then 
    @all_players4 = Teamsheet.where(:user_id => u.id)
    @priority_players2 = @all_players4.where(:priority => '1')
    for p in @priority_players2 do
      if p.player.position == 'Striker' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true) 
         @priority_players3 = @all_players4.where(:priority => '2')
         for p in @priority_players3 do 
          if p.player.position == 'Striker' then
            p.validate = true
            p.update(:played => nil)
          end
         end
      else 
        @priority_players3 = @all_players4.where(:priority => '2')
        for p in @priority_players3 do
          if p.player.position == 'Striker' && p.read_attribute(:played) == true then
            p.validate = true
            p.update(:active => true)
          end
        end
     end
  end
    
    elsif strikerSubCount == 2 then 
      @all_players9 = Teamsheet.where(:user_id => u.id)
      @all_priority_players2 = @all_players9.where('priority= ? OR priority= ?', 1, 2)
      for p in @all_priority_players2 do
       if p.player.position == 'Striker' && p.read_attribute(:played) == true then
         p.validate = true
         p.update(:active => true)
       end
    end
  end
end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result.destroy
    respond_to do |format|
      format.html { redirect_to results_url, notice: 'Result was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def updateLeagueTable 
    @accounts = Account.all
    for account in @accounts do
    @table = LeagueTable.order('points DESC').order('gd DESC').order('team ASC')
    matchday_id = Matchday.find(Matchday.where(:account_id => account.id)).read_attribute(:id)
    @matchday = Matchday.find(matchday_id)
    matchday_number = @matchday.read_attribute(:matchday_number)
    matchday_count = @matchday.read_attribute(:matchday_count)
    matchday_haflag = @matchday.read_attribute(:haflag)
    @results = Fixture.where(:matchday => matchday_number).where(:haflag => matchday_haflag).where(:account_id => account.id)
    
    for r in @results do
      hteam = User.find(r.read_attribute(:hteam))
      first_nameh = hteam.teamname
      ateam = User.find(r.read_attribute(:ateam))
      first_namea = ateam.teamname
      finalscore = r.finalscore.to_s
      homescore = finalscore[0].to_i
      awayscore = finalscore[1].to_i
      if homescore > awayscore then
        #add points to the team who won the game and add all other league table statistics.
        currentPoints1 = LeagueTable.find_by_team(first_nameh).read_attribute(:points).to_i
        finalPointsHome1 = currentPoints1 + 3
        lhome = LeagueTable.find_by_team(first_nameh)
        lhome.update(:points => finalPointsHome1)
        updatePlayed(first_nameh, first_namea)
        haflag = "Home"
        updateWonDrawLoss(first_nameh, first_namea, haflag)
        updateForAgainst(first_nameh, first_namea, homescore, awayscore)
        updateGD(first_nameh, first_namea)
      elsif awayscore > homescore
        currentPoints2 = LeagueTable.find_by_team(first_namea).read_attribute(:points).to_i
        finalPointsAway2 = currentPoints2 + 3
        laway = LeagueTable.find_by_team(first_namea)
        laway.update(:points => finalPointsAway2)
        updatePlayed(first_nameh, first_namea)
        haflag = "Away" 
        updateWonDrawLoss(first_nameh, first_namea, haflag)
        updateForAgainst(first_nameh, first_namea, homescore, awayscore)
        updateGD(first_nameh, first_namea)
      elsif homescore == awayscore 
        currentPointsHome3 = LeagueTable.find_by_team(first_nameh).read_attribute(:points).to_i
        finalPointsHome3 = currentPointsHome3 + 1
        currentPointsAway3 = LeagueTable.find_by_team(first_namea).read_attribute(:points).to_i
        finalPointsAway3 = currentPointsAway3 + 1
        lhome1 = LeagueTable.find_by_team(first_nameh)
        lhome1.update(:points => finalPointsHome3)
        laway1 = LeagueTable.find_by_team(first_namea)
        laway1.update(:points => finalPointsAway3)
        updatePlayed(first_nameh, first_namea)
        haflag = "Draw" 
        updateWonDrawLoss(first_nameh, first_namea, haflag)
        updateForAgainst(first_nameh, first_namea, homescore, awayscore)
        updateGD(first_nameh, first_namea)
      else
      end
    end
    @matchday1 = Matchday.find(Matchday.where(:account_id => account.id))
    @matchday1.update(:matchday_number => matchday_number + 1)
    
   matchday_number1 = @matchday1.read_attribute(:matchday_number)
   matchday_count1 = @matchday1.read_attribute(:matchday_count)
   matchday_haflag1 = @matchday1.read_attribute(:haflag)
   if matchday_haflag1 == "Home" && matchday_number1 <= matchday_count1 then
   elsif 
      matchday_haflag1 == "Away" && matchday_number1 <= matchday_count1 then
    else
      if matchday_haflag1 = "Home" then
         @matchday1.update(:matchday_number => 0)
         @matchday1.update(:haflag => "Away")
      else
        @matchday1.update(:matchday_number => 0)
        @matchday1.update(:haflag => "Home")
      end
    end
    Result.delete_all   
    #update the amount of games a player has played. 
    @teamsheets = Teamsheet.where(:account_id => account.id)
    for t in @teamsheets do 
      currentPlayed = t.played
      overallPlayed = Playerstat.find_by_player_id(t.player_id).played
      if currentPlayed == true then
        currentPlayedValue = 1
      else
        currentPlayedValue = 0
      end
      newPlayed = currentPlayedValue.to_i + overallPlayed.to_i
      Playerstat.find_by_player_id(t.player_id).update(:played => newPlayed)
    end
    
    @teamsheets = Teamsheet.where(:account_id => account.id)
    for t in @teamsheets do
      currentScored = t.scored
      overallScored = Playerstat.find_by_player_id(t.player_id).scored
      if currentScored == true then
        currentScoredValue = 1
      else
        currentScoredValue = 0
      end
      newScored = currentScoredValue.to_i + overallScored.to_i
      Playerstat.find_by_player_id(t.player_id).update(:scored => newScored)
    end

    @teamsheets = Teamsheet.where(:account_id => account.id)
    for t in @teamsheets do
      currentConceded = t.conceded
      overallConceded = Playerstat.find_by_player_id(t.player_id).conceded
      if currentConceded == true then
       currentConcededValue = 1
      else
       currentConcededValue = 0
      end
      newConceded = currentConcededValue.to_i + overallConceded.to_i
      Playerstat.find_by_player_id(t.player_id).update(:conceded => newConceded)
    end

    @teamsheets = Teamsheet.where(:account_id => account.id)
    for t in @teamsheets do
      currentScoreNum = t.scorenum
      overallScoreNum = Playerstat.find_by_player_id(t.player_id).scorenum
      newScoreNum = currentScoreNum.to_i + overallScoreNum.to_i
      Playerstat.find_by_player_id(t.player_id).update(:scorenum => newScoreNum)
    end

   @teamsheets = Teamsheet.where(:account_id => account.id)
    for t in @teamsheets do
      currentConcededNum = t.concedednum
      overallConcededNum = Playerstat.find_by_player_id(t.player_id).concedednum
      newConcededNum = currentConcededNum.to_i + overallConcededNum.to_i
      Playerstat.find_by_player_id(t.player_id).update(:concedednum => newConcededNum)
    end
    #Teamsheet.where(:account_id => current_user.account_id).where("priority IS NULL").update_all(:active => true)
    #Teamsheet.where(:account_id => current_user.account_id).where("priority IS NOT NULL").update_all(:active => false)
  end
  end

  def updatePlayed(homeTeam, awayTeam)
    homeCurrentPlayed = LeagueTable.find_by_team(homeTeam).read_attribute(:played).to_i
    awayCurrentPlayed = LeagueTable.find_by_team(awayTeam).read_attribute(:played).to_i
    homeNewPlayed = homeCurrentPlayed + 1
    awayNewPlayed = awayCurrentPlayed + 1
    home = LeagueTable.find_by_team(homeTeam)
    away = LeagueTable.find_by_team(awayTeam)
    home.update(:played => homeNewPlayed)
    away.update(:played => awayNewPlayed)
end

def updateWonDrawLoss(homeTeam, awayTeam, haflag)
  if haflag == "Home" then
    homeCurrentWon = LeagueTable.find_by_team(homeTeam).read_attribute(:won).to_i
    homeNewWon = homeCurrentWon + 1
    home = LeagueTable.find_by_team(homeTeam)
    home.update(:won => homeNewWon)

    awayCurrentLost = LeagueTable.find_by_team(awayTeam).read_attribute(:lost).to_i
    awayNewLost = awayCurrentLost + 1
    away = LeagueTable.find_by_team(awayTeam)
    away.update(:lost => awayNewLost)

  elsif haflag == "Away"
    awayCurrentWon = LeagueTable.find_by_team(awayTeam).read_attribute(:won).to_i
    awayNewWon = awayCurrentWon + 1
    away = LeagueTable.find_by_team(awayTeam)
    away.update(:won => awayNewWon)

    homeCurrentLost = LeagueTable.find_by_team(homeTeam).read_attribute(:lost).to_i
    homeNewLost = homeCurrentLost + 1
    home = LeagueTable.find_by_team(homeTeam)
    home.update(:lost => homeNewLost)

  elsif haflag == "Draw"
    homeCurrentDraw = LeagueTable.find_by_team(homeTeam).read_attribute(:drawn).to_i
    homenewDraw = homeCurrentDraw + 1
    home = LeagueTable.find_by_team(homeTeam)
    home.update(:drawn => homenewDraw)
    awayCurrentDraw = LeagueTable.find_by_team(awayTeam).read_attribute(:drawn).to_i
    awaynewDraw = awayCurrentDraw + 1
    away = LeagueTable.find_by_team(awayTeam)
    away.update(:drawn => awaynewDraw)
  else
end
end

def updateForAgainst(homeTeam, awayTeam, homescore, awayscore)
homeCurrentFor = LeagueTable.find_by_team(homeTeam).read_attribute(:for).to_i
homeNewFor = homeCurrentFor + homescore
home = LeagueTable.find_by_team(homeTeam)
home.update(:for => homeNewFor)
homeCurrentAgainst = LeagueTable.find_by_team(homeTeam).read_attribute(:against).to_i
homeNewAgainst = homeCurrentAgainst + awayscore
home.update(:against => homeNewAgainst)

awayCurrentFor = LeagueTable.find_by_team(awayTeam).read_attribute(:for).to_i
awayNewFor = awayCurrentFor + awayscore
away = LeagueTable.find_by_team(awayTeam)
away.update(:for => awayNewFor)
awayCurrentAgainst = LeagueTable.find_by_team(awayTeam).read_attribute(:against).to_i
awayNewAgainst = awayCurrentAgainst + homescore
away.update(:against => awayNewAgainst)
end

def updateGD(homeTeam, awayTeam)
homeCurrentFor = LeagueTable.find_by_team(homeTeam).read_attribute(:for).to_i
homeCurrentAgainst = LeagueTable.find_by_team(homeTeam).read_attribute(:against).to_i
homeGD = homeCurrentFor - homeCurrentAgainst
home = LeagueTable.find_by_team(homeTeam)
home.update(:gd => homeGD)

awayCurrentFor = LeagueTable.find_by_team(awayTeam).read_attribute(:for).to_i
awayCurrentAgainst = LeagueTable.find_by_team(awayTeam).read_attribute(:against).to_i
awayGD = awayCurrentFor - awayCurrentAgainst
away = LeagueTable.find_by_team(awayTeam)
away.update(:gd => awayGD)
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_result
      @result = Result.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def result_params
      params.fetch(:result, {})
    end
end
