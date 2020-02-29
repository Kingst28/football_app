class SessionsController < ApplicationController
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
            redirect_to '/bids/insertWinners' and return
            elsif timer_date < Time.now() && current_bid_count = 3 then
            Timer.destroy(timer_id)
            Account.find(@user.account_id).update(:bid_count => current_bid_count + 1)
            redirect_to '/bids/insertWinners' and return
            else
          end
          else
          end
          
          if Account.find(@user.account_id).new_results_ready == true
            Account.find(@user.account_id).update(:new_results_ready => false)
            redirect_to '/results/fixture_results' and return
          else
          end

          if Account.find(current_user.account_id).bid_count == 4 then
            insertRandomPlayers()
          end

          if current_user.admin? 
          redirect_to '/admin_index' and return
          elsif current_user.user?
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
    end
    insertGoalkeepers(user_id, goalkeepers, user_account_id)
    insertDefenders(user_id, defenders, user_account_id)
    insertMidfielders(user_id, midfielders, user_account_id)
    insertStrikers(user_id, strikers, user_account_id)
    current_bid_count = Account.find(current_user.account_id).bid_count
    Account.find(current_user.account_id).update(:bid_count => current_bid_count + 1)
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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save
  elsif goalkeepers == 1 then
    @account_players = Player.where(:position => 'Goalkeeper').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    
    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true",  :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save
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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

    @teamsheet_new_6 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_6, :active => "true", :account_id => user_account_id)
    @teamsheet_new_6.validate = true
    @teamsheet_new_6.save

    @bid_new_6 = Bid.new(:user_id => user_id, :player_id => random_player_id_6, :amount => 0, :account_id => user_account_id)
    @bid_new_6.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

elsif defenders == 4 then
  @account_players = Player.where(:position => 'Defender').where(:taken => 'No').where(:account_id => user_account_id)
  random_player_id_1 = @account_players.sample.id
  random_player_id_2 = @account_players.sample.id

  @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
  @teamsheet_new_1.validate = true
  @teamsheet_new_1.save

  @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
  @bid_new_2.save

  @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
  @teamsheet_new_2.validate = true
  @teamsheet_new_2.save

  @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
  @bid_new_2.save

elsif defenders == 5 then
  @account_players = Player.where(:position => 'Defender').where(:taken => 'No')
  random_player_id_1 = @account_players.sample.id

  @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
  @teamsheet_new_1.validate = true

  @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
  @bid_new_1.save
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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

    @teamsheet_new_6 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_6, :active => "true", :account_id => user_account_id)
    @teamsheet_new_6.validate = true
    @teamsheet_new_6.save

    @bid_new_6 = Bid.new(:user_id => user_id, :player_id => random_player_id_6, :amount => 0, :account_id => user_account_id)
    @bid_new_6.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

    @teamsheet_new_5 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_5, :active => "true", :account_id => user_account_id)
    @teamsheet_new_5.validate = true
    @teamsheet_new_5.save

    @bid_new_5 = Bid.new(:user_id => user_id, :player_id => random_player_id_5, :amount => 0, :account_id => user_account_id)
    @bid_new_5.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

elsif midfielders == 4 then
  @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
  random_player_id_1 = @account_players.sample.id
  random_player_id_2 = @account_players.sample.id

  @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
  @teamsheet_new_1.validate = true
  @teamsheet_new_1.save

  @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
  @bid_new_1.save

  @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
  @teamsheet_new_2.validate = true
  @teamsheet_new_2.save

  @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
  @bid_new_2.save

elsif midfielders == 5 then
  @account_players = Player.where(:position => 'Midfielder').where(:taken => 'No').where(:account_id => user_account_id)
  random_player_id_1 = @account_players.sample.id

  @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
  @teamsheet_new_1.validate = true
  @teamsheet_new_1.save

  @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
  @bid_new_1.save
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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

    @teamsheet_new_4 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_4, :active => "true", :account_id => user_account_id)
    @teamsheet_new_4.validate = true
    @teamsheet_new_4.save

    @bid_new_4 = Bid.new(:user_id => user_id, :player_id => random_player_id_4, :amount => 0, :account_id => user_account_id)
    @bid_new_4.save

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

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

    @teamsheet_new_3 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_3, :active => "true", :account_id => user_account_id)
    @teamsheet_new_3.validate = true
    @teamsheet_new_3.save

    @bid_new_3 = Bid.new(:user_id => user_id, :player_id => random_player_id_3, :amount => 0, :account_id => user_account_id)
    @bid_new_3.save

  elsif strikers == 2 then
    @account_players = Player.where(:position => 'Striker').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id
    random_player_id_2 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save

    @teamsheet_new_2 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_2, :active => "true", :account_id => user_account_id)
    @teamsheet_new_2.validate = true
    @teamsheet_new_2.save

    @bid_new_2 = Bid.new(:user_id => user_id, :player_id => random_player_id_2, :amount => 0, :account_id => user_account_id)
    @bid_new_2.save

  elsif strikers == 3 then
    @account_players = Player.where(:position => 'Striker').where(:taken => 'No').where(:account_id => user_account_id)
    random_player_id_1 = @account_players.sample.id

    @teamsheet_new_1 = Teamsheet.new(:user_id => user_id, :player_id => random_player_id_1, :active => "true", :account_id => user_account_id)
    @teamsheet_new_1.validate = true
    @teamsheet_new_1.save

    @bid_new_1 = Bid.new(:user_id => user_id, :player_id => random_player_id_1, :amount => 0, :account_id => user_account_id)
    @bid_new_1.save
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
end