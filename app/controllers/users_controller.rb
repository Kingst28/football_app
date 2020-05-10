class UsersController < ApplicationController
	def new 
		@user = User.new
	end

	def signup_options
		
	end

	def create 
	 @user = User.new(user_params) 
  	 if @user.save 
    	session[:user_id] = @user.id 
    	UserMailer.account_activation(@user).deliver
        flash[:info] = "Please check your email to activate your account."
        redirect_to '/login'
  	 else 
        render 'new' 
  	 end 
	end

	private
  		def user_params
    	params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :account_id)
		end
end
