class User < ActiveRecord::Base
	has_secure_password
  attr_accessor :password_confirmation
  validates :email, :presence => {:message => "address must be present", :on => :create},
                    :uniqueness=> {:message => "address already exists please login",  :on => :create}
  validates :password, :presence => {:message => "must be present",  :on => :create},
                    :length => { :minimum => 5, :maximum => 40, :message => 'must be a minimum of 5 characters long',  :on => :create },
                    :confirmation => {:message => "must equal the same value",  :on => :create}
  validates_confirmation_of :password
end
