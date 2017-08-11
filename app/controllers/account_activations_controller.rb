class AccountActivationsController < ApplicationController
	def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)
      flash[:success] = "Account activated!"
        if current_user.admin? 
          redirect_to '/admin_index'
        elsif current_user.user?
          redirect_to '/index'
        else
          flash[:danger] = "Invalid activation link"
          redirect_to '/login'
        end
    end
  end
end
