class Teamsheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :player
end
