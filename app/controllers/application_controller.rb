class ApplicationController < ActionController::Base
include SessionsHelper
before_action :require_user, only: [:admin_index, :index]
before_action :require_admin, only: [:admin_index]
before_action :require_participant, only: [:index]
before_filter :authorize_admin, :only => :admin_index
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?, :canView?, :adminUser?

def admin_index
end 

def manage_permissions
end

def admin_controls
end

def manage_permissions_off
  @users = User.all
  for u in @users do 
    u.update_attribute(:canView, "no")
  end
  flash[:error] = "user permissions revoked"
    if require_admin then
    redirect_to '/admin_index'
    else
    redirect_to '/index' 
  end
  end

def manage_permissions_on
  @users = User.all
  for u in @users do 
    u.update_attribute(:canView, "yes")
  end
  flash[:error] = "user permissions granted"
    if require_admin then
    redirect_to '/admin_index'
    else
    redirect_to '/index' 
  end
  end  

def index
end 

def current_user 
  @current_user ||= User.find(session[:user_id]) if session[:user_id] 
end

protected

def canView? 
  current_user.canView == "yes"
end

protected

def adminUser?
  current_user.access == "admin"
end

def authorize_admin 
  unless adminUser?
    flash[:error] = "unauthorized access"
    if require_admin then
    redirect_to '/admin_index'
    else
    redirect_to '/index' 
  end
  end
end

def authorize
  unless canView?
    flash[:error] = "unauthorized access"
    if require_admin then
    redirect_to '/admin_index'
    else
    redirect_to '/index' 
  end
end
  false
end

def logged_in?
  current_user != nil
end

def require_admin
  current_user.admin?
end

def require_participant
   current_user.user?	
end

def require_user 
  redirect_to '/login' unless current_user 
end
end