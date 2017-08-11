class ApplicationController < ActionController::Base
include SessionsHelper
before_action :require_user, only: [:admin_index, :index]
before_action :require_admin, only: [:admin_index]
before_action :require_participant, only: [:index]
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?

def admin_index
end 

def index
end 

def current_user 
  @current_user ||= User.find(session[:user_id]) if session[:user_id] 
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