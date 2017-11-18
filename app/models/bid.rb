class Bid < ActiveRecord::Base
  belongs_to :user
  belongs_to :player
  validates :amount, :numericality => { :less_than_or_equal_to => 1000000 }

    def canView? 
    self.canView == 'Yes' 
    end
end
