class SessionsController < ApplicationController
  require "round_robin_tournament"
  def new
  end
  
  def create
   @user = User.find_by_email(params[:session][:email])
   if @user && @user.authenticate(params[:session][:password])
    if @user.activated?
      session[:user_id] = @user.id
      if Timer.where(:account_id => @user.account_id).exists? 
          @timer = Timer.where(:account_id => @user.account_id)
          timer_id_array = @timer.pluck(:id)
          timer_id = timer_id_array[0]
          timer_date_array = @timer.pluck(:date)
          timer_date = timer_date_array[0]
          current_bid_count = Account.find(@user.account_id).bid_count
          if timer_date < Time.now() && current_bid_count < 3 then
            Account.find(@user.account_id).update(:bid_count => current_bid_count + 1)
            Timer.destroy(timer_id)
            timer_start = Time.now
            timer_end = timer_start + 172800
            date_end = timer_end.strftime("%b %d, %Y %T") # => "Feb 10, 2020 12:29:56"
            Timer.create(:date => date_end, :account_id => @user.account_id)
            insertWinners()
            redirect_to '/index' and return
          elsif timer_date < Time.now() && current_bid_count == 3 then
            Timer.destroy(timer_id)
            Account.find(@user.account_id).update(:bid_count => current_bid_count + 1)
            insertWinners()
            redirect_to '/index' and return
          else
          end
          else
          end
          
          if @user.account_id != nil 
          if Account.find(@user.account_id).new_results_ready == true
            #squad_validity_check()
            Account.find(@user.account_id).update(:new_results_ready => false)
            redirect_to '/results/fixture_results' and return
          else
          end
          end
          
          if @user.account_id != nil
          if Account.find(@user.account_id).bid_count == 4 then
            insertRandomPlayers()
            createFixtures()
            redirect_to '/index' and return
          end
          end

          if @user.account_id != nil
            if Account.find(@user.account_id).bid_count > 4 then
                @account_bids = Bid.where(:account_id => @user.account_id)
                @timer = Timer.where(:account_id => @user.account_id)
                timer_id_array = @timer.pluck(:id)
                timer_id = timer_id_array[0]
                timer_date_array = @timer.pluck(:date)
                timer_date1 = timer_date_array[0]
                if timer_date1 != nil then
                  timer_date = timer_date1.to_datetime
                end
                if @account_bids.joins(:player).where("players.taken = ?", "No").exists? && timer_date != nil
                  if timer_date.past? then
                    Timer.destroy(timer_id)
                    insertWinners()
                    @teamsheets_not_in_bids = Teamsheet.find_by_sql("SELECT * FROM teamsheets WHERE player_id NOT IN (SELECT player_id FROM bids);")
                    for teamsheet in @teamsheets_not_in_bids do
                      teamsheet.destroy
                    end
                    @transfer_out_bids = Bid.where(:refunded => true)
                    if @transfer_out_bids.exists? 
                      for bid in @transfer_out_bids do
                          amount = bid.amount
                          user_id = bid.user_id
                          budget = User.find(user_id).budget
                          newBudget = budget - amount
                          User.find(user_id).update_attribute(:budget, newBudget)
                      end
                    end
                    @account_bids.update_all(:transfer_out => false)
                    @account_bids.update_all(:refunded => false)
                    redirect_to '/index' and return
                  else
                    redirect_to '/index' and return
                  end
            end
          end
          end

          if @user.admin? 
          redirect_to '/admin_controls' and return
          elsif @user.user?
          redirect_to '/index' and return
          else
            message = "Account not activated. "
            message += "Check your email with the activation link."
            flash[:danger] = message
            redirect_to '/login' and return
          end 
          end 
    else
     flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
     render 'new'
    end
  end

 def show
 end

 def calculateMatchdayResults
    fixture_results()
    flash[:success] = 'Results Calculated'
    redirect_to '/admin_controls' and return
  end

 def insertRandomPlayers
  #need to add the taken to player model to equal Yes when a random player is assigned in teamsheets and bids.
  #also need to add the player name concat with player team to the random records across all models
  @users = User.where(:account_id => current_user.account_id) 
  goalkeepers = 0
  defenders = 0
  midfielders = 0
  strikers = 0
  for user in @users do 
    user_id = user.id
    user_account_id = user.account_id
    @teamsheet_players = Teamsheet.where(:user_id => user.id).where(:account_id => user.account_id)
    playerCount = @teamsheet_players.length
    if playerCount != 18 then 
      for p in @teamsheet_players do 
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
        insertGoalkeepers(user_id, goalkeepers, user_account_id)
        insertDefenders(user_id, defenders, user_account_id)
        insertMidfielders(user_id, midfielders, user_account_id)
        insertStrikers(user_id, strikers, user_account_id)
        current_bid_count = Account.find(current_user.account_id).bid_count
        Account.find(current_user.account_id).update(:bid_count => current_bid_count + 1)
    else
      current_bid_count = Account.find(current_user.account_id).bid_count
      Account.find(current_user.account_id).update(:bid_count => current_bid_count + 1)
    end
  end
  end

 def insertGoalkeepers (user_id, goalkeepers, user_account_id)
  if goalkeepers == 0 then
    @account_players = Player.where(:position => 'Goalkeeper').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')
  
   elsif goalkeepers == 1 then
    @account_players = Player.where(:position => 'Goalkeeper').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    
    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true",  :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')
  end
 end
 
 def insertDefenders (user_id, defenders, user_account_id)
  if defenders == 0 then
    @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id
    random_player_id_5 = @account_players.sample.id
    random_player_id_6 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    player_4 = Player.find(random_player_id_4)
    player_4.update(taken: 'Yes')

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

    player_5 = Player.find(random_player_id_5)
    player_5.update(taken: 'Yes')

    @teamsheet_new_6 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_6, :active => "true", :account_id => user_account_id)
    @teamsheet_new_6.validate = true
    @teamsheet_new_6.save

    @bid_new_6 = Bid.new(:user_id => user_id, :player_id => random_player_id_6, :amount => 0, :account_id => user_account_id)
    @bid_new_6.save

    player_6 = Player.find(random_player_id_6)
    player_6.update(taken: 'Yes')

   elsif defenders == 1 then
    @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id
    random_player_id_5 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    player_4 = Player.find(random_player_id_4)
    player_4.update(taken: 'Yes')

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

    player_5 = Player.find(random_player_id_5)
    player_5.update(taken: 'Yes')

   elsif defenders == 2 then
    @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    @player_1 = Player.where(:id => random_player_id_1)
    @player_1.update(:taken, 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save
    
    @player_2 = Player.where(:id => random_player_id_2)
    @player_2.update(:taken, 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @player_3 = Player.where(:id => random_player_id_3)
    @player_3.update(:taken, 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    @player_4 = Player.where(:id => random_player_id_4)
    @player_4.update(:taken, 'Yes')

   elsif defenders == 3 then
    @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    @player_1 = Player.where(:id => random_player_id_1)
    @player_1.update(:taken, 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @player_2 = Player.where(:id => random_player_id_2)
    @player_2.update(:taken, 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @player_3 = Player.where(:id => random_player_id_3)
    @player_3.update(:taken, 'Yes')

   elsif defenders == 4 then
    @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    @player_1 = Player.where(:id => random_player_id_1)
    @player_1.update(:taken, 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @player_2 = Player.where(:id => random_player_id_2)
    @player_2.update(:taken, 'Yes')

   elsif defenders == 5 then
    @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')
  end
 end

 def insertMidfielders (user_id, midfielders, user_account_id)
  if midfielders == 0 then
    @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id
    random_player_id_5 = @account_players.sample.id
    random_player_id_6 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    player_4 = Player.find(random_player_id_4)
    player_4.update(taken: 'Yes')

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

    player_5 = Player.find(random_player_id_5)
    player_5.update(taken: 'Yes')

    @teamsheet_new_6 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_6, :active => "true", :account_id => user_account_id)
    @teamsheet_new_6.validate = true
    @teamsheet_new_6.save

    @bid_new_6 = Bid.new(:user_id => user_id, :player_id => random_player_id_6, :amount => 0, :account_id => user_account_id)
    @bid_new_6.save

    player_6 = Player.find(random_player_id_6)
    player_6.update(taken: 'Yes')

   elsif midfielders == 1 then
    @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id
    random_player_id_5 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    player_4 = Player.find(random_player_id_4)
    player_4.update(taken: 'Yes')

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

    player_5 = Player.find(random_player_id_5)
    player_5.update(taken: 'Yes')

   elsif midfielders == 2 then
    @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    player_4 = Player.find(random_player_id_4)
    player_4.update(taken: 'Yes')

   elsif midfielders == 3 then
    @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

   elsif midfielders == 4 then
    @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

   elsif midfielders == 5 then
    @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')
  end
 end

 def insertStrikers (user_id, strikers, user_account_id)
  if strikers == 0 then
    @account_players = Player.where(:position => 'Striker').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id
    random_player_id_4 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    player_4 = Player.find(random_player_id_4)
    player_4.update(taken: 'Yes')

   elsif strikers == 1 then
    @account_players = Player.where(:position => 'Striker').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id
    random_player_id_3 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    player_3 = Player.find(random_player_id_3)
    player_3.update(taken: 'Yes')

   elsif strikers == 2 then
    @account_players = Player.where(:position => 'Striker').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    player_2 = Player.find(random_player_id_2)
    player_2.update(taken: 'Yes')

   elsif strikers == 3 then
    @account_players = Player.where(:position => 'Striker').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    player_1 = Player.find(random_player_id_1)
    player_1.update(taken: 'Yes')
  end
 end

 def createFixtures 
  @users = User.where(:account_id => current_user.account_id)
  users = []
  for u in @users do
  users << u.id
  end
  
  @teams = RoundRobinTournament.schedule(users)
  @teams.each_with_index do |day, index|
  @day_teams = day.map { |team| "(#{team.first},#{team.last})" }
  @day_teams_reverse = day.map { |team| "(#{team.last},#{team.first})" }
  
  for t in @day_teams do
   hteam = t.split(',').first
   hteam.delete! '()'
   ateam = t.split(',').last
   ateam.delete! '()'
   @fixture = Fixture.new(:matchday => "#{index}".to_i, :hteam => hteam, :ateam => ateam, :haflag => "Home", :account_id => u.account_id)
   @fixture.save
  end
  
  for t1 in @day_teams_reverse do
   hteam1 = t1.split(',').first
   hteam1.delete! '()'
   ateam1 = t1.split(',').last
   ateam1.delete! '()'
   @fixture1 = Fixture.new(:matchday => "#{index}".to_i, :hteam => hteam1, :ateam => ateam1, :haflag => "Away", :account_id => u.account_id)
   @fixture1.save
  end
  end

  teamCount = @users.length
  matchday_count = teamCount - 2
  @matchday_data = Matchday.new(:matchday_number => 0, :matchday_count => 18, :haflag => "Home", :account_id => u.account_id)
  @matchday_data.save

  prem_matchdays = matchday_count * 2
  index = 0
  while matchday_count < 17 do
    @fixtures = Fixture.where(:matchday => index).where(:account_id => u.account_id)
    for fixture in @fixtures do
      @new_fixture = fixture.dup
      @new_fixture.update_attribute(:matchday, matchday_count + 1)
      @new_fixture.save
    end
     prem_matchdays_new = prem_matchdays + 1
     prem_matchdays = prem_matchdays_new * 2
     matchday_count = matchday_count + 1
     index =  index + 1
  end

  for u in @users do
    @table_team = LeagueTable.new(:team => u.teamname, :account_id => u.account_id)
    @table_team.save
  end
 end

 def edit
   @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
 end

 def user_param
    params.require(:user).permit(:first_name, :last_name, :email)
 end

 def update
   @user = User.find(params[:id])
   if @user.update_attributes(user_param)
    redirect_to '/index'
   end
  end

  def destroy 
   session[:user_id] = nil 
   redirect_to '/login' 
  end

  def checkBids 
    @bids = Bid.all
    @playerbids = []
    @duplicates = Bid.select("player_id, user_id, amount, MAX(amount)").group(:player_id).having("count(*) > 1")
  end
  
 def insertWinners
    @user = User.find_by_email(params[:session][:email])
    @notifications_all = Notification.where(:user_id => @user.id).order("created_at DESC")
    @notify_users = User.all 
    account_id = @user.account_id
    @users = User.where(:account_id => @user.account_id)
    for u in @users do
     @outrightWinners = Bid.where(:user_id => u.id)
     @highest_amount = Bid.find_by_sql("SELECT DISTINCT player_id, MAX(amount) as amount from bids GROUP BY player_id HAVING COUNT(*) > 1;")
     @duplicates1 = Bid.find_by_sql("SELECT * FROM bids WHERE player_id IN (SELECT player_id FROM bids GROUP BY player_id HAVING COUNT(*) > 1);")
     @final_duplicates = []
     for element in @highest_amount do
      @final_duplicates << @duplicates1.select { |record| record.amount == element.read_attribute(:amount) }
     end
     for d in @final_duplicates do
      if Teamsheet.exists?(:player_id => d[0].player_id)
       Player.find(d[0].player_id).update_column(:taken,"Yes")
       else
        @destroyOtherBids = Bid.where(:player_id => d[0].player_id).where.not(:user_id => d[0].user_id)
        refunded = false
        @destroyOtherBids.each do |b| 
        bidAmount = b.read_attribute(:amount) 
        if b.read_attribute(:amount).to_i == d[0].amount.to_i && refunded == false then
          @user = User.find(d[0].user_id)
          currentBudget = @user.budget.to_i
          newBudget = currentBudget + d[0].amount.to_i
        if newBudget > 1000000 then
          @user.update_attribute(:budget, 1000000)
         else
          @user.update_attribute(:budget, newBudget)
        end
       @user1 = User.find(b.read_attribute(:user_id))
       currentBudget1 = @user1.budget.to_i
       newBudget1 = currentBudget1 + b.read_attribute(:amount).to_i
       @user1.update_attribute(:budget, newBudget1)
       @deleteBids = Bid.where(:player_id => d[0].player_id).destroy_all
       refunded = true
       else
          @user1 = User.find(b.read_attribute(:user_id))
          currentBudget1 = @user1.budget
          newBudget1 = currentBudget1 + bidAmount
          @user1.update_attribute(:budget, newBudget1)
       if Bid.exists?(b.read_attribute(:id))
          @bidDelete1 = Bid.find(b.read_attribute(:id)).destroy
       else
       end
       end
       end
    end
   end
    for o in @outrightWinners do
      if Teamsheet.exists?(:player_id => o.player_id)
          Player.find(o.player_id).update_column(:taken,"Yes")
      else
          Player.find(o.player_id).update_column(:taken,"Yes")
          @teamsheet_new = Teamsheet.new(:user_id => o.user_id, :player_id => o.player_id, :amount => o.amount, :account_id => o.account_id, :name => Player.find(o.player_id).read_attribute(:playerteam), :bid_id => o.id)
          player_position = Player.find(o.player_id).position
          goalkeeper_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Goalkeeper").size
          defender_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Defender").size
          midfielder_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Midfielder").size
          striker_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Striker").size
          
          @goalkeeper_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Goalkeeper", 1, false).size
          @defender_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Defender", 1, false).size
          @defender_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Defender", 2, false).size
          @mid_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Midfielder", 1, false).size
          @mid_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Midfielder", 2, false).size
          @str_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Striker", 1, false).size
          @str_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Striker", 2, false).size
          
          if player_position == "Goalkeeper"
            @bid = Bid.joins(:player).where("bids.user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, 'Goalkeeper', true).order('bids.id')
            if @bid.exists?
              bid_id = @bid.first.read_attribute(:id)
              player_id = @bid.first.read_attribute(:player_id)
              teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
              active = Teamsheet.where(:player_id => player_id).pluck(:active)
              priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
              teamsheet_id = teamsheet[0]
              active = active[0]
              priority = priority[0]
              @teamsheet_new.assign_attributes(:active => active, :priority => priority)
              @bidDelete = Bid.find(bid_id).destroy
              @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
            end
            gk_pri(goalkeeper_count, @goalkeeper_priority1_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id, o.id)
          elsif player_position == "Defender"
            @bid = Bid.joins(:player).where("bids.user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, 'Defender', true).order('bids.id')
            if @bid.exists?
                bid_id = @bid.first.read_attribute(:id)
                player_id = @bid.first.read_attribute(:player_id)
                teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
                active = Teamsheet.where(:player_id => player_id).pluck(:active)
                priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
                teamsheet_id = teamsheet[0]
                active = active[0]
                priority = priority[0]
                @teamsheet_new.assign_attributes(:active => active, :priority => priority)
                @bidDelete = Bid.find(bid_id).destroy
                @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
            end
            defender_pri(defender_count, @defender_priority1_count, @defender_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id, o.id)
          elsif player_position == "Midfielder"
            @bid = Bid.joins(:player).where("bids.user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, 'Midfielder', true).order('bids.id')
            if @bid.exists?
              bid_id = @bid.first.read_attribute(:id)
              player_id = @bid.first.read_attribute(:player_id)
              teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
              active = Teamsheet.where(:player_id => player_id).pluck(:active)
              priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
              teamsheet_id = teamsheet[0]
              active = active[0]
              priority = priority[0]
              @teamsheet_new.assign_attributes(:active => active, :priority => priority)
              @bidDelete = Bid.find(bid_id).destroy
              @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
            end
            midfielder_pri(midfielder_count, @mid_priority1_count, @mid_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id, o.id) 
          elsif player_position == "Striker"
            @bid = Bid.joins(:player).where("bids.user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, 'Striker', true).order('bids.id')
            if @bid.exists?
              bid_id = @bid.first.read_attribute(:id)
              player_id = @bid.first.read_attribute(:player_id)
              teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
              active = Teamsheet.where(:player_id => player_id).pluck(:active)
              priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
              teamsheet_id = teamsheet[0]
              active = active[0]
              priority = priority[0]
              @teamsheet_new.assign_attributes(:active => active, :priority => priority)
              @bidDelete = Bid.find(bid_id).destroy
              @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
            end
            striker_pri(striker_count, @str_priority1_count, @str_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id, o.id)
          end
          @teamsheet_new.validate = true
          @teamsheet_new.save
    flash[:success] = "Successful bids inserted"
  end
  end
  end
  end

 def squad_validity_check 
    @users = User.all
    for u in @users do
      goalkeeper_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", u.id, "Goalkeeper").count
      goalkeeper_active_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Goalkeeper", true).count
      goalkeeper_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", u.id, "Goalkeeper", 1, false).count
      defender_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", u.id, "Defender").count
      defender_active_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Defender", true).count
      defender_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ?", u.id, "Defender", 1).size
      defender_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", u.id, "Defender", 2, false).size
      midfielder_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", u.id, "Midfielder").count
      midfielder_active_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Midfielder", true).count
      midfielder_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", u.id, "Midfielder", 1, false).count
      midfielder_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", u.id, "Midfielder", 2, false).count
      striker_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", u.id, "Striker").count
      striker_active_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Striker", true).count
      striker_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Striker", false, 1).count
      striker_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Striker", false, 2).count

      goalkeeper_validity_check(u,goalkeeper_count, goalkeeper_active_count, goalkeeper_priority1_count)
      defender_validity_check(u,defender_count, defender_active_count, defender_priority1_count, defender_priority2_count)
      midfielder_validity_check(u,midfielder_count, midfielder_active_count, midfielder_priority1_count, midfielder_priority2_count)
      striker_validity_check(u,striker_count, striker_active_count, striker_priority1_count, striker_priority2_count)
  end
  end

 def goalkeeper_validity_check (u, goalkeeper_count, goalkeeper_active_count, goalkeeper_priority1_count)
    if goalkeeper_active_count != 1 then
      @goalkeepers = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", u.id, "Goalkeeper").order(updated_at: :desc)
      @gk1 = @goalkeepers[0]
      @gk2 = @goalkeepers[1]

      @gk1.update_attributes(:active => true, :priority => nil)
      @gk2.update_attributes(:active => false, :priority => 1)

    elsif goalkeeper_active_count == 1 && goalkeeper_priority1_count == 0 then
      @gkprinil = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Goalkeeper", false)
      @gkprinil[0].update_attributes(:active => false, :priority => 1)
    end
  end

 def defender_validity_check (u, defender_count, defender_active_count, defender_priority1_count, defender_priority2_count)
   if defender_active_count != 4 then
    @defender_inactive_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Defender", false).order(updated_at: :desc)
    if defender_active_count == 0 then
      @def1 = @defender_inactive_count[0]
      @def2 = @defender_inactive_count[1]
      @def3 = @defender_inactive_count[2]
      @def4 = @defender_inactive_count[3]
      @def5 = @defender_inactive_count[4]
      @def6 = @defender_inactive_count[5]
      
      @def1.update_attributes(:active => true, :priority => nil)
      @def2.update_attributes(:active => true, :priority => nil)
      @def3.update_attributes(:active => true, :priority => nil)
      @def4.update_attributes(:active => true, :priority => nil)
      @def5.update_attributes(:active => false, :priority => 1)
      @def6.update_attributes(:active => false, :priority => 2)
    
     elsif defender_active_count == 1 then 
      @def1 = @defender_inactive_count[0]
      @def2 = @defender_inactive_count[1]
      @def3 = @defender_inactive_count[2]
      @def4 = @defender_inactive_count[3]
      @def5 = @defender_inactive_count[4]
      
      @def1.update_attributes(:active => true, :priority => nil)
      @def2.update_attributes(:active => true, :priority => nil)
      @def3.update_attributes(:active => true, :priority => nil)
      @def4.update_attributes(:active => false, :priority => 1)
      @def5.update_attributes(:active => false, :priority => 2)
    
     elsif defender_active_count == 2 then 
      @def1 = @defender_inactive_count[0]
      @def2 = @defender_inactive_count[1]
      @def3 = @defender_inactive_count[2]
      @def4 = @defender_inactive_count[3]
      
      @def1.update_attributes(:active => true, :priority => nil)
      @def2.update_attributes(:active => true, :priority => nil)
      @def3.update_attributes(:active => false, :priority => 1)
      @def4.update_attributes(:active => false, :priority => 2)

     elsif defender_active_count == 3 then 
      @def1 = @defender_inactive_count[0]
      @def2 = @defender_inactive_count[1]
      @def3 = @defender_inactive_count[2]
    
      @def1.update_attributes(:active => true, :priority => nil)
      @def2.update_attributes(:active => false, :priority => 1)
      @def3.update_attributes(:active => false, :priority => 2)
   end

   elsif defender_active_count == 4 && defender_priority1_count == 1 && defender_priority2_count == 0 then
    @defnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Defender", false)
    @defnilpri[0].update_attributes(:active => false, :priority => 2)

   elsif defender_active_count == 4 && defender_priority1_count == 0 && defender_priority2_count == 1 then
    @defnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Defender", false)
    @defnilpri[0].update_attributes(:active => false, :priority => 1)

   elsif defender_active_count == 4 && defender_priority1_count == 2 && defender_priority2_count == 0 then
    @defnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Defender", false, 1).order(updated_at: :desc)
    player_id = @defnilpri.pluck(:id)
    Teamsheet.find(player_id[1]).update_attribute('priority', 2)

   elsif defender_active_count == 4 && defender_priority1_count == 0 && defender_priority2_count == 2 then
    @defnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Defender", false, 2).order(updated_at: :desc)
    player_id = @defnilpri.pluck(:id)
    Teamsheet.find(player_id[1]).update_attribute('priority', 1)

   elsif defender_active_count == 4 && defender_priority1_count == 0 && defender_priority2_count == 0 then
    @defnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Defender", false).order(updated_at: :desc)
    player_id = @defnilpri.pluck(:id)
    Teamsheet.find(player_id[0]).update_attribute('priority', 1)  
    Teamsheet.find(player_id[1]).update_attribute('priority', 2)  
  end    
 end

 def midfielder_validity_check (u, midfielder_count, midfielder_active_count, midfielder_priority1_count, midfielder_priority2_count)
  if midfielder_active_count != 4 then
   @midfielder_inactive_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Midfielder", false).order(updated_at: :desc)
  if midfielder_active_count == 0 then
    @mid1 = @midfielder_inactive_count[0]
    @mid2 = @midfielder_inactive_count[1]
    @mid3 = @midfielder_inactive_count[2]
    @mid4 = @midfielder_inactive_count[3]
    @mid5 = @midfielder_inactive_count[4]
    @mid6 = @midfielder_inactive_count[5]
    
    @mid1.update_attributes(:active => true, :priority => nil)
    @mid2.update_attributes(:active => true, :priority => nil)
    @mid3.update_attributes(:active => true, :priority => nil)
    @mid4.update_attributes(:active => true, :priority => nil)
    @mid5.update_attributes(:active => false, :priority => 1)
    @mid6.update_attributes(:active => false, :priority => 2)
  
   elsif midfielder_active_count == 1 then 
    @mid1 = @midfielder_inactive_count[0]
    @mid2 = @midfielder_inactive_count[1]
    @mid3 = @midfielder_inactive_count[2]
    @mid4 = @midfielder_inactive_count[3]
    @mid5 = @midfielder_inactive_count[4]
    
    @mid1.update_attributes(:active => true, :priority => nil)
    @mid2.update_attributes(:active => true, :priority => nil)
    @mid3.update_attributes(:active => true, :priority => nil)
    @mid4.update_attributes(:active => false, :priority => 1)
    @mid5.update_attributes(:active => false, :priority => 2)

   elsif midfielder_active_count == 2 then 
    @mid1 = @midfielder_inactive_count[0]
    @mid2 = @midfielder_inactive_count[1]
    @mid3 = @midfielder_inactive_count[2]
    @mid4 = @midfielder_inactive_count[3]
    
    @mid1.update_attributes(:active => true, :priority => nil)
    @mid2.update_attributes(:active => true, :priority => nil)
    @mid3.update_attributes(:active => false, :priority => 1)
    @mid4.update_attributes(:active => false, :priority => 2)

   elsif midfielder_active_count == 3 then 
    @mid1 = @midfielder_inactive_count[0]
    @mid2 = @midfielder_inactive_count[1]
    @mid3 = @midfielder_inactive_count[2]
  
    @mid1.update_attributes(:active => true, :priority => nil)
    @mid2.update_attributes(:active => false, :priority => 1)
    @mid3.update_attributes(:active => false, :priority => 2)
  end

 elsif midfielder_active_count == 4 && midfielder_priority1_count == 0 && midfielder_priority2_count == 1 then
  @midnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Midfielder", false)
  @midnilpri[0].update_attributes(:active => false, :priority => 1)

 elsif midfielder_active_count == 4 && midfielder_priority1_count == 1 && midfielder_priority2_count == 0 then
  @midnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Midfielder", false)
  @midnilpri[0].update_attributes(:active => false, :priority => 2)

 elsif midfielder_active_count == 4 && midfielder_priority1_count == 2 && midfielder_priority2_count == 0 then
  @midnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Midfielder", false, 1).order(updated_at: :desc)
  player_id = @midnilpri.pluck(:id)
  Teamsheet.find(player_id[1]).update_attribute('priority', 2)

 elsif midfielder_active_count == 4 && midfielder_priority1_count == 0 && midfielder_priority2_count == 2 then
  @midnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Midfielder", false, 2).order(updated_at: :desc)
  player_id = @midnilpri.pluck(:id)
  Teamsheet.find(player_id[1]).update_attribute('priority', 1)

 elsif midfielder_active_count == 4 && midfielder_priority1_count == 0 && midfielder_priority2_count == 0 then
  @midnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Midfielder", false).order(updated_at: :desc)
  player_id = @midnilpri.pluck(:id)
  Teamsheet.find(player_id[0]).update_attribute('priority', 1)  
  Teamsheet.find(player_id[1]).update_attribute('priority', 2)  
 end
 end

 def striker_validity_check (u, striker_count, striker_active_count, striker_priority1_count, striker_priority2_count)
  if striker_active_count != 2 then
  @striker_inactive_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Striker", false).order(updated_at: :desc)
  if striker_active_count == 0 then
    @stk1 = @striker_inactive_count[0]
    @stk2 = @striker_inactive_count[1]
    @stk3 = @striker_inactive_count[2]
    @stk4 = @striker_inactive_count[3]
    
    @stk1.update_attributes(:active => true, :priority => nil)
    @stk2.update_attributes(:active => true, :priority => nil)
    @stk3.update_attributes(:active => false, :priority => 1)
    @stk4.update_attributes(:active => false, :priority => 2)
  
   elsif striker_active_count == 1 then 
    @stk1 = @striker_inactive_count[0]
    @stk2 = @striker_inactive_count[1]
    @stk3 = @striker_inactive_count[2]
    @stk4 = @striker_inactive_count[3]
    
    @stk1.update_attributes(:active => true, :priority => nil)
    @stk2.update_attributes(:active => true, :priority => nil)
    @stk3.update_attributes(:active => false, :priority => 1)
    @stk4.update_attributes(:active => false, :priority => 2)
   end

   elsif striker_active_count == 2 && striker_priority1_count == 0 && striker_priority2_count == 1 then
    @strnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Striker", false)
    @strnilpri[0].update_attributes(:active => false, :priority => 1)

   elsif striker_active_count == 2 && striker_priority1_count == 1 && striker_priority2_count == 0 then
    @strnilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority IS NULL", u.id, "Striker", false)
    @strnilpri[0].update_attributes(:active => false, :priority => 2)
 
   elsif striker_active_count == 2 && striker_priority1_count == 2 && striker_priority2_count == 0 then
    @strikernilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Striker", false, 1).order(updated_at: :desc)
    player_id = @strikernilpri.pluck(:id)
    Teamsheet.find(player_id[1]).update_attribute('priority', 2)
  
   elsif striker_active_count == 2 && striker_priority1_count == 0 && striker_priority2_count == 2 then
    @strikernilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ? AND priority = ?", u.id, "Striker", false, 2).order(updated_at: :desc)
    player_id = @strikernilpri.pluck(:id)
    Teamsheet.find(player_id[1]).update_attribute('priority', 1)

   elsif striker_active_count == 1 && striker_priority1_count == 0 && striker_priority2_count == 0 then
    @strikernilpri = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND active = ?", u.id, "Striker", false).order(updated_at: :desc)
    player_id = @strikernilpri.pluck(:id)
    Teamsheet.find(player_id[0]).update_attribute('priority', 1)  
    Teamsheet.find(player_id[1]).update_attribute('priority', 2)  
  end
 end

 def subtract_amount
  @bidCount = Bid.where(:user_id => current_user.id)
  @bidAmount = @bidCount.pluck(:amount)
  total = 0
  for bid in @bidAmount do 
    total += bid
  end
  @user = current_user
  bidamount = 1000000
  newbudget = bidamount - total
  total = 0
  if newbudget < 0
    flash[:danger] = "You have exceeded your budget"
  else
  @user.update_attribute(:budget, newbudget)
  end
 end

 def subtract_update_amount
  @bidCount = Bid.where(:user_id => current_user.id)
  @bidAmount = @bidCount.pluck(:amount)
  total = 0
  for bid in @bidAmount do 
    total += bid
  end
  @user = current_user
  bidamount = 1000000
  newbudget = bidamount - total
  total = 0
  if newbudget < 0
    flash[:danger] = "You have exceeded your budget"
  else
  @user.update_attribute(:budget, newbudget)
  end
 end
 
 def gk_pri(gk_count, gk_pri_1, user_id, player_id, name, amount, account_id, bid_id)
  if gk_count == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id, :bid_id => bid_id)
   elsif gk_count == 1 && gk_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif gk_count == 1 && gk_pri_1 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id, :bid_id => bid_id)
  end
 end
   
 def defender_pri(defender_count, def_pri_1, def_pri_2, user_id, player_id, name, amount, account_id, bid_id)
  if defender_count < 4
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id, :bid_id => bid_id)
   elsif defender_count == 4 && def_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif defender_count == 5 && def_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif defender_count == 5 && def_pri_2 == 0
      @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id, :bid_id => bid_id)
   elsif defender_count == 4 && def_pri_1 == 1
      @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id, :bid_id => bid_id)
   elsif defender_count == 5 && def_pri_2 == 1
      @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   end
 end
    
 def midfielder_pri(midfielder_count, mid_pri_1, mid_pri_2, user_id, player_id, name, amount, account_id, bid_id)
  if midfielder_count < 4
   @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id, :bid_id => bid_id)
   elsif midfielder_count == 4 && mid_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif midfielder_count == 5 && mid_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif midfielder_count == 5 && mid_pri_2 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id, :bid_id => bid_id)
   elsif midfielder_count == 4 && mid_pri_1 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id, :bid_id => bid_id)
   elsif midfielder_count == 5 && mid_pri_2 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
  end
 end
    
 def striker_pri(striker_count, str_pri_1, str_pri_2, user_id, player_id, name, amount, account_id, bid_id)
  if striker_count < 2
   @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id, :bid_id => bid_id)
   elsif striker_count == 2 && str_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif striker_count == 3 && str_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
   elsif striker_count == 3 && str_pri_2 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id, :bid_id => bid_id)
   elsif striker_count == 2 && str_pri_1 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id, :bid_id => bid_id)
   elsif striker_count == 3 && str_pri_2 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id, :bid_id => bid_id)
  end
 end
 
 def fixture_results
  @accounts = Account.all
  for account in @accounts do
  @users = User.where(:account_id => account.id)
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
@fixtures = Fixture.where(:matchday => matchday_number).where(:haflag => 'Home').where(:account_id => u.account_id)
elsif 
matchday_haflag == 'Away' && matchday_number <= matchday_count then
@fixtures = Fixture.where(:matchday => matchday_number).where(:haflag => 'Away').where(:account_id => u.account_id)
else
if matchday_haflag = 'Home' then
   matchday_id = Matchday.find(Matchday.where(:account_id => u.account_id)).read_attribute(:id)
   @matchday = Matchday.find(matchday_id)
   @matchday.update(:matchday_number => 0)
   @matchday.update(:haflag => 'Away'.to_s)
   @fixtures = Fixture.where(:matchday => 0).where(:haflag => 'Away').where(:account_id => u.account_id)
   @matchday.update(:matchday_number => 0 + 1)
else
  matchday_id = Matchday.find(Matchday.where(:account_id => u.account_id)).read_attribute(:id)
  @matchday = Matchday.find(matchday_id)
  @matchday.update(:matchday_number => 0)
  @matchday.update(:haflag => 'Home')
  @fixtures = Fixture.where(:matchday => 0).where(:haflag => 'Home').where(:account_id => u.account_id)
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
updateLeagueTable(account.id)
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

def updateLeagueTable(account_id)
@table = LeagueTable.order('points DESC').order('gd DESC').order('team ASC')
matchday_id = Matchday.find(Matchday.where(:account_id => account_id)).read_attribute(:id)
@matchday = Matchday.find(matchday_id)
matchday_number = @matchday.read_attribute(:matchday_number)
matchday_count = @matchday.read_attribute(:matchday_count)
matchday_haflag = @matchday.read_attribute(:haflag)
@results = Fixture.where(:matchday => matchday_number).where(:haflag => matchday_haflag).where(:account_id => account_id)

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
@matchday1 = Matchday.find(Matchday.where(:account_id => account_id))
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
@teamsheets = Teamsheet.where(:account_id => account_id)
for t in @teamsheets do 
  currentPlayed = t.played
  #overallPlayed = Playerstat.find_by_player_id(t.player_id).played
  if currentPlayed == true then
    currentPlayedValue = 1
  else
    currentPlayedValue = 0
  end
  #newPlayed = currentPlayedValue.to_i + overallPlayed.to_i
  #Playerstat.find_by_player_id(t.player_id).update(:played => newPlayed)
end

@teamsheets = Teamsheet.where(:account_id => account_id)
for t in @teamsheets do
  currentScored = t.scored
  #overallScored = Playerstat.find_by_player_id(t.player_id).scored
  if currentScored == true then
    currentScoredValue = 1
  else
    currentScoredValue = 0
  end
  #newScored = currentScoredValue.to_i + overallScored.to_i
  #Playerstat.find_by_player_id(t.player_id).update(:scored => newScored)
end

@teamsheets = Teamsheet.where(:account_id => account_id)
for t in @teamsheets do
  currentConceded = t.conceded
  #overallConceded = Playerstat.find_by_player_id(t.player_id).conceded
  if currentConceded == true then
   currentConcededValue = 1
  else
   currentConcededValue = 0
  end
  #newConceded = currentConcededValue.to_i + overallConceded.to_i
  #Playerstat.find_by_player_id(t.player_id).update(:conceded => newConceded)
end

@teamsheets = Teamsheet.where(:account_id => account_id)
for t in @teamsheets do
  currentScoreNum = t.scorenum
  #overallScoreNum = Playerstat.find_by_player_id(t.player_id).scorenum
  #newScoreNum = currentScoreNum.to_i + overallScoreNum.to_i
  #Playerstat.find_by_player_id(t.player_id).update(:scorenum => newScoreNum)
end

@teamsheets = Teamsheet.where(:account_id => account_id)
for t in @teamsheets do
  currentConcededNum = t.concedednum
  #overallConcededNum = Playerstat.find_by_player_id(t.player_id).concedednum
  #newConcededNum = currentConcededNum.to_i + overallConcededNum.to_i
  #Playerstat.find_by_player_id(t.player_id).update(:concedednum => newConcededNum)
end
#Teamsheet.where(:account_id => current_user.account_id).where("priority IS NULL").update_all(:active => true)
#Teamsheet.where(:account_id => current_user.account_id).where("priority IS NOT NULL").update_all(:active => false)
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