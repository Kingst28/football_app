class LeagueTableController < ApplicationController
   
   def updateLeagueTable 
    #find out why this method runs twice in Safari?
    #fix the matchday count as this is no longer switching over to Away and back to zero once matchday_count is met.
    @table = LeagueTable.order('points DESC').order('gd DESC').order('team ASC')
    @matchday = Matchday.find(9)
    matchday_number = @matchday.read_attribute(:matchday_number)
    matchday_count = @matchday.read_attribute(:matchday_count)
    matchday_haflag = @matchday.read_attribute(:haflag)
    @results = Fixture.where(:matchday => matchday_number).where(:haflag => matchday_haflag)
    
    for r in @results do
      hteam = User.find(r.read_attribute(:hteam))
      first_nameh = hteam.first_name
      ateam = User.find(r.read_attribute(:ateam))
      first_namea = ateam.first_name
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
    @matchday1 = Matchday.find(9)
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
    #Teamsheet.update_all(:played => null)
    #Teamsheet.update_all(:scored => null)
    #Teamsheet.update_all(:scorenum => null)
    #Teamsheet.update_all(:conceded => null)
    #Teamsheet.update_all(:concedednum => null)
  end

  def viewLeagueTable 
    @table = LeagueTable.order('points DESC').order('gd DESC').order('team ASC')
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
end
