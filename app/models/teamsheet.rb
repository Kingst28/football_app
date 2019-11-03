class Teamsheet < ActiveRecord::Base
  acts_as_tenant(:account)
  belongs_to :user
  belongs_to :player
end
