class Team < ActiveRecord::Base
	acts_as_tenant(:account)
	has_many :players
end
