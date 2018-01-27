class BidsController < ApplicationController
  include SessionsHelper
  before_action :set_bid, only: [:show, :edit, :update, :destroy]
  before_action :require_canView, :only => :new
  before_filter :authorize, :except => :index
  helper_method :current_user, :logged_in?, :canView?

  # GET /bids
  # GET /bids.json
  def index
    @bids = Bid.all 
    @players = Bid.where(:user_id => current_user.id)
    
    @goalkeeper = []
    @defender = []
    @midfielder = []
    @striker = []
    
    @players.each do |p|
    
    if p.read_attribute(:position) == 'Goalkeeper' then
      @goalkeeper << p
    elsif p.read_attribute(:position) == 'Defender' then
      @defender << p
    elsif p.read_attribute(:position) == 'Midfielder' then
      @midfielder << p
    elsif p.read_attribute(:position) == 'Striker' then
      @striker << p
    end
  end
end

def current_user 
  @current_user ||= User.find(session[:user_id]) if session[:user_id] 
end

def require_canView
  current_user.canView?
end

  # GET /bids/1
  # GET /bids/1.json
  def showall
     @bids = Bid.all
  end

  # GET /bids/new 
  def new
    @bid = Bid.new
    #create a flag in player model which sets if players have been won or not here. 
    @player_options = Player.order('teams_id ASC').where(:taken => "No")
  end

  def checkBids 
    @bids = Bid.all
    @playerbids = []
    @duplicates = Bid.select("player_id, user_id, amount, MAX(amount)").group(:player_id).having("count(*) > 1")
  end
  
  def insertWinners
    @users = User.all
    for u in @users do
    @outrightWinners = Bid.where(:user_id => u.id)
    @duplicates = Bid.select("SELECT user_id, COUNT(player_id), MAX(amount) FROM bids GROUP BY player_id HAVING COUNT (player_id) > 1") 
    for d in @duplicates do
      if Teamsheet.exists?(:player_id => d.player_id)
       Player.find(d.player_id).update_column(:taken,"Yes")
      else
       @teamsheet_new = Teamsheet.new(:user_id => d.user_id, :player_id => d.player_id, :amount => d.amount, :active => "true")
       @teamsheet_new.save
       @notification_new = Notification.new(:user_id => u.id, :message => "You have successfully won a player for #{d.amount}")
       @notification_new.save
       @destroyOtherBids = Bid.where(:player_id => d.player_id).where.not(:user_id => d.user_id)
       refunded = false
       @destroyOtherBids.each do |b| 
       bidAmount = b.read_attribute(:amount) 
       if b.read_attribute(:amount).to_i == d.amount.to_i && refunded == false then
       @user = User.find(d.user_id)
       currentBudget = @user.budget.to_i
       newBudget = currentBudget + d.amount.to_i
       if newBudget > 1000000 then
       @user.update_attribute(:budget, 1000000)
       else
       @user.update_attribute(:budget, newBudget)
       end
       @user1 = User.find(b.read_attribute(:user_id))
       currentBudget1 = @user1.budget.to_i
       newBudget1 = currentBudget1 + b.read_attribute(:amount).to_i
       @user1.update_attribute(:budget, newBudget1)
       @deleteTeamsheet = Teamsheet.where(:player_id => d.player_id).destroy_all
       @deleteBids = Bid.where(:player_id => d.player_id).destroy_all
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
      @teamsheet_new = Teamsheet.new(:user_id => o.user_id, :player_id => o.player_id, :amount => o.amount, :active => "true")
      @teamsheet_new.save
      @notify_users = User.all 
      
      for nu in @notify_users do
        if nu.id == u.id 
        else
        @notification_new = Notification.new(:user_id => nu.id, :message => "#{u.first_name} has successfully won #{Player.find(o.player_id).name} for £#{o.amount}", :show => "yes")
        @notification_new.save
      end
      end
      @notification_new = Notification.new(:user_id => u.id, :message => "You have successfully won #{Player.find(o.player_id).name} for £#{o.amount}", :show => "yes")
      @notification_new.save
      end
      end
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
        @notification_new = Notification.new(:user_id => nu.id, :message => "#{User.find(current_user.id).first_name} has bid on #{Player.find(bid_params[:player_id]).name}", :show => "yes")
        @notification_new.save
      end
      end
    @notification_new = Notification.new(:user_id => current_user.id, :message => "#{User.find(current_user.id).first_name} has bid on #{Player.find(bid_params[:player_id]).name}", :show => "yes")
    @notification_new.save
    respond_to do |format|
      if @bid.save 
        subtract_amount()
        format.html { redirect_to '/bids' }
        format.json { render :show, status: :created, location: @bid }
      else
        format.html { render :new }
        format.json { render json: @bid.errors, status: :unprocessable_entity }
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
    @teamsheetDelete = Teamsheet.where(player_id: player_id).destroy_all
    @playerUpdate = Player.find(player_id).update_column(:taken, "No")
    bidAmount = Bid.find(params[:id]).amount
    @user = current_user
    currentBudget = @user.budget
    newBudget = currentBudget + bidAmount
    @user = current_user
    @user.update_attribute(:budget, newBudget)
    @bidDelete = Bid.find(params[:id]).destroy
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
      params.require(:bid).permit(:player_id, :amount, :user_id)
   end
end
