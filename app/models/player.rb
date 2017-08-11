class Player < ActiveRecord::Base
	belongs_to :team
	has_many :bids
	searchable do
		text :name
		integer :teams_id
	end
end
