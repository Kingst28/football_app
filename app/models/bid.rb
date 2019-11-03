class Bid < ActiveRecord::Base
attr_accessor :remember_token, :activation_token, :reset_token
  belongs_to :user
  belongs_to :player
  validates :amount, :numericality => { :less_than_or_equal_to => 1000000 }
  acts_as_tenant(:account)
end