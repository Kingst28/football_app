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
            #insertRandomPlayers()
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
   redirect_to '/uffl' 
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
     @duplicates1 = Bid.find_by_sql("SELECT * FROM bids WHERE player_id IN (SELECT player_id FROM bids GROUP BY player_id HAVING COUNT(*) > 1)")
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
        if newBudget > 1200000 then
          @user.update_attribute(:budget, 1200000)
         else
          @user.update_attribute(:budget, newBudget)
        end
       @user1 = User.find(b.read_attribute(:user_id))
       currentBudget1 = @user1.budget.to_i
       newBudget1 = currentBudget1 + b.read_attribute(:amount).to_i
       @user1.update_attribute(:budget, newBudget1)
       @deleteBids = Bid.where(:player_id => d[0].player_id).destroy_all
       @deleteTeamsheet = Teamsheet.where(:player_id => d[0].player_id).destroy_all
       refunded = true
       else
          @user1 = User.find(b.read_attribute(:user_id))
          currentBudget1 = @user1.budget
          newBudget1 = currentBudget1 + bidAmount
          @user1.update_attribute(:budget, newBudget1)
       if Bid.exists?(b.read_attribute(:id))
          teamsheet = Teamsheet.where(:player_id => b.read_attribute(:player_id)).pluck(:id)
          teamsheet_id = teamsheet[0]
          @teamsheetDelete = Teamsheet.where(player_id: b.read_attribute(:player_id)).destroy_all
          @bidDelete1 = Bid.find(b.read_attribute(:id)).destroy
       else
          teamsheet = Teamsheet.where(:player_id => b.read_attribute(:player_id)).pluck(:id)
          teamsheet_id = teamsheet[0]
          @teamsheetDelete = Teamsheet.where(player_id: b.read_attribute(:player_id)).destroy_all
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
          @teamsheet_new = Teamsheet.new(:user_id => o.user_id, :player_id => o.player_id, :amount => o.amount, :account_id => o.account_id, :name => Player.find(o.player_id).read_attribute(:playerteam))
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
            @bid = Bid.joins(:player).where("user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, "Goalkeeper", true).order(updated_at: :asc)
            if @bid.exists?
              bid_id = @bid.first.read_attribute(:id)
              player_id = @bid.first.read_attribute(:player_id)
              teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
              active = Teamsheet.where(:player_id => player_id).pluck(:active)
              priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
              teamsheet_id = teamsheet[0]
              active = active[0]
              priority = priority[0]
              @teamsheetDelete = Teamsheet.find(teamsheet_id).delete
              @bidDelete = Bid.find(bid_id).delete
              @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
              @teamsheet_new.assign_attributes(:active => active, :priority => priority)
            end
            gk_pri(goalkeeper_count, @goalkeeper_priority1_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id)
          elsif player_position == "Defender"
            @bid = Bid.joins("JOIN players ON bids.player_id = players.id").where("bids.user_id = ? AND bids.transfer_out = ? AND bids.account_id = ? AND players.position = ?", o.user_id, true, o.account_id, 'Defender').order('bids.id asc')
            if @bid.exists?
              for bid in @bid do 
                bid_id = bid.read_attribute(:id)
                player_id = bid.read_attribute(:player_id)
                teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => bid.read_attribute(:account_id)).pluck(:id)
                active = Teamsheet.where(:player_id => player_id).pluck(:active)
                priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
                teamsheet_id = teamsheet[0]
                active = active[0]
                priority = priority[0]
                @teamsheetDelete = Teamsheet.find(teamsheet_id).destroy
                @bidDelete = Bid.find(bid_id).destroy
                @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
                @teamsheet_new.assign_attributes(:active => active, :priority => priority)
              end
            end
            defender_pri(defender_count, @defender_priority1_count, @defender_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id)
          elsif player_position == "Midfielder"
            @bid = Bid.joins(:player).where("user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, "Midfielder", true).order(updated_at: :asc)
            if @bid.exists?
              bid_id = @bid.first.read_attribute(:id)
              player_id = @bid.first.read_attribute(:player_id)
              teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
              active = Teamsheet.where(:player_id => player_id).pluck(:active)
              priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
              teamsheet_id = teamsheet[0]
              active = active[0]
              priority = priority[0]
              @bidDelete = Bid.find(bid_id).delete
              @teamsheetDelete = Teamsheet.find(teamsheet_id).delete
              @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
              @teamsheet_new.assign_attributes(:active => active, :priority => priority)
            end
            midfielder_pri(midfielder_count, @mid_priority1_count, @mid_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id) 
          elsif player_position == "Striker"
            @bid = Bid.joins(:player).where("user_id = ? AND players.position = ? AND bids.transfer_out = ?", o.user_id, "Striker", true).order(updated_at: :asc)
            if @bid.exists?
              bid_id = @bid.first.read_attribute(:id)
              player_id = @bid.first.read_attribute(:player_id)
              teamsheet = Teamsheet.where(:player_id => player_id).where(:account_id => @bid.first.read_attribute(:account_id)).pluck(:id)
              active = Teamsheet.where(:player_id => player_id).pluck(:active)
              priority = Teamsheet.where(:player_id => player_id).pluck(:priority)
              teamsheet_id = teamsheet[0]
              active = active[0]
              priority = priority[0]
              @bidDelete = Bid.find(bid_id).delete
              @teamsheetDelete = Teamsheet.find(teamsheet_id).delete
              @playerTaken = Player.find(player_id).update_attribute(:taken, "No")
              @teamsheet_new.assign_attributes(:active => active, :priority => priority)
            end
            striker_pri(striker_count, @str_priority1_count, @str_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id)
          end
          @teamsheet_new.validate = true
          @teamsheet_new.save
    flash[:success] = "Successful bids inserted"
  end
  end
  end
  end

 #def deleteBidTeam (bid_id, player_id)
  #@bid = Bid.find(bid_id)
  #bid_uid = @bid.user_id
  #@bids = Bid.where(:user_id => bid_uid)
  #for bid in @bids do 
    #if bid.read_attribute(:transfer_out => false) then 
      #bid.update_attribute(:replacement, true)
      #bid.save
    #elsif bid.read_attribute(:transfer_out => true) then
      #bid.update_attribute(:replacement, false)
      #bid.save
    #end
  #end
  #@teamsheetDelete = Teamsheet.where(player_id: player_id).destroy_all
  #@bidDelete = Bid.find(bid_id).delete
 #end

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
 
 def gk_pri(gk_count, gk_pri_1, user_id, player_id, name, amount, account_id)
  if gk_count == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id)
   elsif gk_count == 1 && gk_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif gk_count == 1 && gk_pri_1 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id)
  end
 end
   
 def defender_pri(defender_count, def_pri_1, def_pri_2, user_id, player_id, name, amount, account_id)
  if defender_count < 4
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id)
   elsif defender_count == 4 && def_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif defender_count == 5 && def_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif defender_count == 5 && def_pri_2 == 0
      @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id)
   elsif defender_count == 4 && def_pri_1 == 1
      @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id)
   elsif defender_count == 5 && def_pri_2 == 1
      @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   end
 end
    
 def midfielder_pri(midfielder_count, mid_pri_1, mid_pri_2, user_id, player_id, name, amount, account_id)
  if midfielder_count < 4
   @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id)
   elsif midfielder_count == 4 && mid_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif midfielder_count == 5 && mid_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif midfielder_count == 5 && mid_pri_2 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id)
   elsif midfielder_count == 4 && mid_pri_1 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id)
   elsif midfielder_count == 5 && mid_pri_2 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
  end
 end
    
 def striker_pri(striker_count, str_pri_1, str_pri_2, user_id, player_id, name, amount, account_id)
  if striker_count < 2
   @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "true", :account_id => account_id)
   elsif striker_count == 2 && str_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif striker_count == 3 && str_pri_1 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
   elsif striker_count == 3 && str_pri_2 == 0
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id)
   elsif striker_count == 2 && str_pri_1 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 2, :account_id => account_id)
   elsif striker_count == 3 && str_pri_2 == 1
    @teamsheet_new = Teamsheet.new(:user_id => user_id, :player_id => player_id, :name => name, :amount => amount, :active => "false", :priority => 1, :account_id => account_id)
  end
 end 
end