class Player < ActiveRecord::Base
	acts_as_tenant(:account)
	belongs_to :team
	has_many :bids
	#searchable do
		#text :name
		#integer :teams_id
	#end
end
