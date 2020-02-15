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