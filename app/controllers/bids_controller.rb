class BidsController < ApplicationController
  include SessionsHelper
  #before_action :require_user
  before_action :set_bid, only: [:show, :edit, :update, :destroy]
  before_action :require_canView, :only => :new
  before_filter :authorize, :except => :index
  before_filter :authorize_admin, only: [:insertWinners]
  helper_method :current_user, :logged_in?, :canView?

  # GET /bids
  # GET /bids.json
def index
  @bids = Bid.all 
  players = Bid.joins(:player).order("position = 'Goalkeeper' desc, position = 'Defender' desc, position = 'Midfielder' desc, position = 'Striker'").where(:user_id => current_user.id)
  @players = players    
  @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
end

def current_user 
  @current_user ||= User.find(session[:user_id]) if session[:user_id] 
end

def require_canView
  current_user.canView?
end
      
def notificationStatus
  if Notification.exists? 
    show = Notification.first.read_attribute(:show)
    return show
  else 
    return "no"
  end
end

  # GET /bids/1
  # GET /bids/1.json
  def showall
     @bids = Bid.all
  end

  # GET /bids/new 
  def new
    @bid = Bid.new
    @goalkeepers = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Goalkeeper")
    @defenders = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Defender")
    @midfielders = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Midfielder")
    @strikers = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Striker")
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
  end

  def checkBids 
    @bids = Bid.all
    @playerbids = []
    @duplicates = Bid.select("player_id, user_id, amount, MAX(amount)").group(:player_id).having("count(*) > 1")
  end

  def transferOut
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
    player_id = params[:player_id]
    @bid = Bid.where(:player_id => player_id).first
    @bid.update_attribute(:transfer_out, true)
    @bid.save
    amount = Bid.where(:player_id => player_id).pluck(:amount)[0]
    @position = Player.find(player_id).read_attribute(:position)
    @user = User.find(current_user.id)
    user_budget =  @user.read_attribute(:budget)
    user_new_budget = user_budget + amount
    @user.update_attribute(:budget, user_new_budget)

    @bid1 = Bid.new
    @goalkeepers = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Goalkeeper")
    @defenders = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Defender")
    @midfielders = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Midfielder")
    @strikers = Player.order('teams_id ASC').where(:taken => "No").where(:position => "Striker")
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
    #redirect_to '/bids/new' and return
  end

  def insertWinners
    @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
    @users = User.where(:account_id => current_user.account_id)
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
       @deleteTeamsheet = Teamsheet.where(:player_id => d[0].player_id).destroy_all
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
          player_position = Player.find(o.player_id).position
          goalkeeper_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Goalkeeper").count(:all)
          defender_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Defender").count(:all)
          midfielder_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Midfielder").count(:all)
          striker_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ?", o.user_id, "Striker").count(:all)
          
          goalkeeper_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Goalkeeper", 1, false).count(:all)
          defender_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Defender", 1, false).count(:all)
          defender_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Defender", 2, false).count(:all)
          mid_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Midfielder", 1, false).count(:all)
          mid_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Midfielder", 2, false).count(:all)
          str_priority1_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Striker", 1, false).count(:all)
          str_priority2_count = Teamsheet.joins(:player).where("user_id = ? AND players.position = ? AND priority = ? AND active = ?", o.user_id, "Striker", 2, false).count(:all)
          
          if player_position == 'Goalkeeper'
            gk_pri(goalkeeper_count, goalkeeper_priority1_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id)
          elsif player_position == 'Defender'
            @bid = Bid.joins(:player).where("user_id = ? AND player.position = ? AND bids.transfer_out = ?", o.user_id, "Defender", true).order(updated_at: :desc)
            if @bid.exists?
              bid_id = @bid.first.pluck(:id)
              @biddestroy = Bid.find(bid_id).destroy
            end
            defender_pri(defender_count, defender_priority1_count, defender_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id)
          elsif player_position == 'Midfielder'
            midfielder_pri(midfielder_count, mid_priority1_count, mid_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id) 
          elsif player_position == 'Striker'
            striker_pri(striker_count, str_priority1_count, str_priority2_count, o.user_id, o.player_id, o.player.playerteam, o.amount, o.account_id)
          end
          @teamsheet_new.validate = true
          @teamsheet_new.save
          @notify_users = User.all 
      
      for nu in @notify_users do
        if nu.id == u.id 
        else
          @notification_new = Notification.new(:user_id => nu.id, :message => "#{u.first_name} has successfully won #{Player.find(o.player_id).playerteam} for £#{o.amount}", :show => "yes", :status => "success", :fname => u.first_name, :account_id => u.account_id)
          @notification_new.save
      end
      end
          @notification_new = Notification.new(:user_id => u.id, :message => "You have successfully won #{Player.find(o.player_id).playerteam} for £#{o.amount}", :show => "yes", :status => "success", :fname => u.first_name, :account_id => u.account_id)
          @notification_new.save
      end
      end
    end
    flash[:success] = "Successful bids inserted"
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
      
  def subtract_amount
    @bidCount = Bid.where(:user_id => current_user.id)
    @bidAmount = @bidCount.pluck(:amount)
    total = 0
    for bid in @bidAmount do 
      total += bid
    end
    @user = current_user
    bidamount = 1200000
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
    bidamount = 1200000
    newbudget = bidamount - total
    total = 0
    if newbudget < 0
      flash[:danger] = "You have exceeded your budget"
    else
    @user.update_attribute(:budget, newbudget)
  end
  end

  # GET /bids/1/edit
  def edit
    @bid = Bid.find(params[:id])
  end

  # POST /bids
  # POST /bids.json
  def create
    @bid = Bid.new(bid_params)
    @bid.user_id = current_user.id 
    @notify_users = User.all 
      
      for nu in @notify_users do
        if nu.id == current_user.id 
        else
        @notification_new = Notification.new(:user_id => nu.id, :message => "#{User.find(current_user.id).teamname} has bid on #{Player.find(bid_params[:player_id]).position} - #{Player.find(bid_params[:player_id]).playerteam}", :show => notificationStatus(), :status => "bid", :fname => User.find(current_user.id).first_name)
        @notification_new.save
      end
      end
        @notification_new = Notification.new(:user_id => current_user.id, :message => "#{User.find(current_user.id).teamname} has bid on #{Player.find(bid_params[:player_id]).position} - #{Player.find(bid_params[:player_id]).playerteam}", :show => notificationStatus(), :status => "bid", :fname => User.find(current_user.id).first_name)
        @notification_new.save
    respond_to do |format|
      if @bid.save 
        subtract_amount()
        format.html { redirect_to '/bids' }
        format.json { render :show, status: :created, location: @bid }
      else
        format.html { redirect_to '/bids/new' }
        if @bid.errors.any?
           @bid.errors.full_messages.each do |message|
           flash[:danger] = message 
         end 
        end 
      end
    end
end

  # PATCH/PUT /bids/1
  # PATCH/PUT /bids/1.json
  def update
    respond_to do |format|
      if @bid.update(bid_params)
        subtract_update_amount()
        format.html { redirect_to '/bids' }
      else
        format.html { render :edit }
        format.json { render json: @bid.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bids/1
  # DELETE /bids/1.json
  def delete 
    player_id = Bid.find(params[:id]).player_id
    @playerUpdate = Player.find(player_id).update_column(:taken, "No")
    @user = current_user
    account_id = current_user.account_id
    @account = Account.find(account_id)
    if @account.read_attribute(:bid_count) > 3 then
      bidAmount = Bid.find(params[:id]).amount
    else
      bidAmount = Bid.find(params[:id]).amount
    end
    currentBudget = @user.budget
    newBudget = currentBudget + bidAmount
    @user = current_user
    @user.update_attribute(:budget, newBudget)
    @bidDelete = Bid.find(params[:id]).destroy
    @teamsheetDelete = Teamsheet.where(player_id: player_id).destroy
    respond_to do |format|
      format.html { redirect_to '/bids'}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bid
      @bid = Bid.find(params[:id])
    end

   def bid_params
      params.require(:bid).permit(:player_id, :amount, :user_id, :transfer_out)
   end
end
