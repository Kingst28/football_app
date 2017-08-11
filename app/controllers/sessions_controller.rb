class SessionsController < ApplicationController
  def new
  end
  
  def create
  @user = User.find_by_email(params[:session][:email])
  if @user && @user.authenticate(params[:session][:password])
        if @user.activated?
          session[:user_id] = @user.id
          if current_user.admin? 
          redirect_to '/admin_index'
        elsif current_user.user?
          redirect_to '/index'
        else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:danger] = message
        redirect_to '/login'
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
end