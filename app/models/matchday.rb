class Matchday < ActiveRecord::Base
    acts_as_tenant(:account)
end
