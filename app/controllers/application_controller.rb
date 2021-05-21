class ApplicationController < ActionController::Base
include SessionsHelper
before_action :require_user, only: [:admin_index, :index]
before_action :require_admin, only: [:admin_index, :admin_db]
before_action :require_participant, only: [:index]
before_action :find_current_tenant
before_filter :authorize_admin, only: [:admin_index, :admin_controls, :manage_permissions]
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?, :canView?, :adminUser?
  set_current_tenant_through_filter

def admin_index
  @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
end 

def rules
  @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
end 

def admin_db 
  @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
end

def find_current_tenant
  if current_user == nil then
    return
  else
    current_account = current_user.account # this line
    set_current_tenant(current_account)
  end
end

def manage_permissions
end

def admin_controls
  @notifications_all = Notification.all
end

def uffl 
end

def notification_settings_off
  ActsAsTenant.without_tenant do
  @notifications_all = Notification.all
  for n in @notifications_all do 
    n.update_attribute(:show, "no")
  end
  flash[:error] = "notification permissions revoked"
    if require_admin then
    redirect_to '/admin_controls'
    else
    redirect_to '/index' 
  end
end
end

def notification_settings_on
  ActsAsTenant.without_tenant do
  @notifications_all = Notification.all
  for n in @notifications_all do 
    n.update_attribute(:show, "yes")
  end
  flash[:error] = "notification permissions revoked"
    if require_admin then
    redirect_to '/admin_controls'
    else
    redirect_to '/index' 
  end
end
end

def manage_permissions_off
ActsAsTenant.without_tenant do
  @users = User.all
  for u in @users do 
    u.update_attribute(:canView, "no")
  end
  flash[:error] = "user permissions revoked"
    if require_admin then
    redirect_to '/admin_controls'
    else
    redirect_to '/index' 
  end
  end
end

def manage_permissions_on
ActsAsTenant.without_tenant do
  @users = User.all
  for u in @users do 
    u.update_attribute(:canView, "yes")
  end
  flash[:error] = "user permissions granted"
    if require_admin then
    redirect_to '/admin_controls'
    else
    redirect_to '/index' 
  end
  end
end

def index
  @notifications_all = Notification.where(:user_id => current_user.id).order("created_at DESC")
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
    redirect_to '/admin_controls'
    else
    redirect_to '/index' 
  end
  end
end

def authorize
  unless canView?
    flash[:error] = "unauthorized access"
    if require_admin then
    redirect_to '/admin_controls'
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