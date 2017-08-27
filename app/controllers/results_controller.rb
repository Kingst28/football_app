class ResultsController < ApplicationController
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
      @users = User.all
      for u in @users do
      total_scorenum = 0
      total_connum = 0
      defenderCount = 0
      scorenum = 0

      @teamsheet_scorers = Teamsheet.where(:user_id => u.id).where(:active => 'true')
      for p in @teamsheet_scorers do
      if(p.read_attribute(:scored) == true) then
      scorenum = p.read_attribute(:scorenum).to_i
      total_scorenum = total_scorenum + scorenum
      else
      end
      end

      @teamsheet_conceders = Teamsheet.where(:user_id => u.id).where(:active => 'true')
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
    con_score = total_connum / defenderCount
    con_score = con_score * -1
    final_score = con_score + total_scorenum
    @result_new = Result.new(:user_id => u.id, :score => final_score)
    @result_new.save
    end
  end
    
    @matchday = Matchday.find(9)
    matchday_number = @matchday.read_attribute(:matchday_number)
    matchday_count = @matchday.read_attribute(:matchday_count)
    matchday_haflag = @matchday.read_attribute(:haflag)
   if matchday_haflag == "Home" && matchday_number <= matchday_count then
      @fixtures = Fixture.where(:matchday => matchday_number).where(:haflag => "Home")
   elsif 
      matchday_haflag == "Away" && matchday_number <= matchday_count then
      @fixtures = Fixture.where(:matchday => matchday_number).where(:haflag => "Away")
    else
      if matchday_haflag = "Home" then
         @matchday = Matchday.find(9)
         @matchday.update(:matchday_number => 0)
         @matchday.update(:haflag => "Away".to_s)
         @fixtures = Fixture.where(:matchday => 0).where(:haflag => "Away")
         @matchday.update(:matchday_number => 0 + 1)
      else
        @matchday = Matchday.find(9)
        @matchday.update(:matchday_number => 0)
        @matchday.update(:haflag => "Home")
        @fixtures = Fixture.where(:matchday => 0).where(:haflag => "Home")
        @matchday.update(:matchday_number => 0 + 1)
      end
    end
    
    for f in @fixtures do
    fuser1 = f.read_attribute(:hteam)
    fuser2 = f.read_attribute(:ateam)
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
end

def updateLeagueTable 
    #need to go through every win/draw/loss combination from the last week to ensure all works correctly. 
    #Loss the week before then draw causes error. Loss and win the week before causes error.  
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
        currentPoints = LeagueTable.find(hteam).read_attribute(:points).to_i
        finalPointsHome = currentPoints + 3
        lhome = LeagueTable.find_by_team(first_nameh)
        lhome.update(:points => finalPointsHome)
      elsif awayscore > homescore
        currentPoints = LeagueTable.find(ateam).read_attribute(:points).to_i
        finalPointsAway = currentPoints + 3
        laway = LeagueTable.find_by_team(first_namea)
        laway.update(:points => finalPointsAway)
            elsif homescore == awayscore 
              currentPointsHome = LeagueTable.find(hteam).read_attribute(:points).to_i
              finalPointsHome = currentPointsHome + 1
              currentPointsAway = LeagueTable.find(ateam).read_attribute(:points).to_i
              finalPointsAway = currentPointsAway + 1
        lhome = LeagueTable.find_by_team(first_nameh)
        lhome.update(:points => finalPointsHome)
        laway = LeagueTable.find_by_team(first_namea)
        laway.update(:points => finalPointsAway)
      else
      end
    end
    if matchday_haflag == "Home" && matchday_number <= matchday_count then
   elsif 
      matchday_haflag == "Away" && matchday_number <= matchday_count then
    else
      if matchday_haflag = "Home" then
         @matchday = Matchday.find(9)
         @matchday.update(:matchday_number => 0)
         @matchday.update(:haflag => "Away")
      else
        @matchday = Matchday.find(9)
        @matchday.update(:matchday_number => 0)
        @matchday.update(:haflag => "Home")
      end
    end
    @matchday = Matchday.find(9)
    @matchday.update(:matchday_number => matchday_number + 1)
    Result.delete_all
    #Teamsheet.update_all(:played => '')
    #Teamsheet.update_all(:scored => '')
    #Teamsheet.update_all(:scorenum => '')
    #Teamsheet.update_all(:conceded => '')
    #Teamsheet.update_all(:concedednum => '')
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