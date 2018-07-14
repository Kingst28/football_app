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
      playedCount = 0
      goalkeepers = 0
      defenders = 0
      midfielders = 0
      strikers = 0

      #Iterate through each player in the teamsheet to get a list of players who are active true and played true. 
      #If that list is not equal to 11 then find the position which it is not equal and pull in a reserve which is played true. 
      #Then run teamsheet conceders and scorers over this new list. 
      #In this system the admin must check the played box over each player for a user, even if they are not active.
      
      #this code does not work
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

      if goalkeepers != 1 then
        @all_players = Teamsheet.where(:user_id => u.id).where(:active => true)
        @false_played_players = @all_players.where(:played => false)
        goalkeeperSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Goalkeeper' then
             goalkeeperSubCount = goalkeeperSubCount + 1
             p.update(:active => false)
           end
         end
      end
      
      if defenders != 4 then
        @all_players = Teamsheet.where(:user_id => u.id).where(:active => true)
        @false_played_players = @all_players.where(:played => false)
        defenderSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Defender' then
             defenderSubCount = defenderSubCount + 1
             p.update(:active => false)
           end
        end
      end

      if midfielders != 4 then
        @all_players = Teamsheet.where(:user_id => u.id)
        @false_played_players = @all_players.where(:played => false)
        midSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Midfielder' then
             midSubCount = midSubCount + 1
             p.update(:active => false)
           end
        end
      end

      if strikers != 2 then
        @all_players = Teamsheet.where(:user_id => u.id)
        @false_played_players = @all_players.where(:played => false)
        strikerSubCount = 0
        for p in @false_played_players do
          if p.player.position == 'Striker' then
             strikerSubCount = strikerSubCount + 1
             p.update(:active => false)
           end
          end
      end
      
      if goalkeeperSubCount = 1 then 
        @all_players2 = Teamsheet.where(:user_id => u.id)
        @priority_players = @all_players2.where(:priority => 1)
        for p in @priority_players do 
          if p.player.position == 'Goalkeeper' then
             p.update(:active => true)
        end
      end
  end
    
    if defenderSubCount = 1 then 
        @all_players4 = Teamsheet.where(:user_id => u.id)
        @priority_players2 = @all_players4.where(:priority => 1)
        for p in @priority_players2 do 
          if p.player.position == 'Defender' && p.read_attribute(:played) == true then
             p.update(:active => true)
          elsif 
            @priority_players3 = @all_players4.where(:priority => 2)
            for p in @priority_players3 do
              if p.player.position == 'Defender' && p.read_attribute(:played) == true then
                p.update(:active => true)
              end
            end
        end
      end
    elsif defenderSubCount = 2 then 
      @all_players7 = Teamsheet.where(:user_id => u.id)
      @all_priority_players = @all_players7.where('priority= ? OR priority= ?', 1, 2)
      if p.player.position == 'Defender' then
         p.update(:active => true)
  end
end

      if midSubCount = 1 then 
        @all_players3 = Teamsheet.where(:user_id => u.id)
        @priority_players1 = @all_players3.where(:priority => 1)
          for p in @priority_players1 do 
            if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
              p.update(:active => true)
            elsif 
              @priority_players2 = @all_players3.where(:priority => 2)
                for p in @priority_players2 do
                  if p.player.position == 'Midfielder' && p.read_attribute(:played) == true then
                    p.update(:active => true)
                end
              end
            end
          end
    elsif midSubCount = 2 then 
        @all_players8 = Teamsheet.where(:user_id => u.id)
        @all_priority_players1 = @all_players8.where('priority= ? OR priority= ?', 1, 2)
      if p.player.position == 'Midfielder' then
         p.update(:active => true)
  end
end

      if strikerSubCount = 1 then 
        @all_players5 = Teamsheet.where(:user_id => u.id)
        @priority_players5 = @all_players5.where(:priority => 1)
        for p in @priority_players5 do 
          if p.player.position == 'Striker' && p.read_attribute(:played) == true then
             p.update(:active => true)
          elsif 
            @priority_players4 = @all_players5.where(:priority => 2)
            for p in @priority_players4 do
              if p.player.position == 'Striker' && p.read_attribute(:played) == true then
                p.update(:active => true)
              end
            end
        end
      end
    elsif strikerSubCount = 2 then 
      @all_players9 = Teamsheet.where(:user_id => u.id)
      @all_priority_players2 = @all_players9.where('priority= ? OR priority= ?', 1, 2)
      if p.player.position == 'Striker' then
         p.update(:active => true)
  end
  end

      @teamsheet_scorers = Teamsheet.where(:user_id => u.id).where(:active => [true, 'true'])
      for p in @teamsheet_scorers do
        if (p.read_attribute(:scored) == true) then
          scorenum = p.read_attribute(:scorenum).to_i
          total_scorenum = total_scorenum + scorenum
        else
      end
      end

      @teamsheet_conceders = Teamsheet.where(:user_id => u.id).where(:active => [true, 'true'])
      for p in @teamsheet_conceders do 
        if(p.read_attribute(:conceded) == true) then
          concedednum = p.read_attribute(:concedednum).to_i 
          total_connum = total_connum + concedednum 
      else
      end
      end

      for p in @teamsheet_conceders do
      if p.player.position == 'Defender' && p.read_attribute(:played) == true then
        defenderCount = defenderCount + 1
      elsif p.player.position == 'Goalkeeper' && p.read_attribute(:played) == true then
        defenderCount = defenderCount + 1
      end
    end

    #This code is no longer running properly. 
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
