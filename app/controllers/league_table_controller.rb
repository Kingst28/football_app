class LeagueTableController < ApplicationController
	#hteams score is the first number thats stored in the database so need to extract the first digit 
	def updateLeagueTable 
		@results = Fixtures.all
		for r in @results do
			hteam = User.find(r.read_attribute(:hteam))
			ateam = User.find(r.read_attribute(:ateam))
			homescore, awayscore = r.finalscore.to_s.split('').map { |digit| digit.to_i }
			if homescore > awayscore then 
				currentPoints = LeagueTable.find(hteam).read_attribute(:points)
				LeagueTable.update(:points => currentPoints + 3).where(:team => User.find(r.read_attribute(:hteam)).first_name)
			elsif awayscore > homescore then
				currentPoints = LeagueTable.find(ateam).read_attribute(:points)
				LeagueTable.update(:points => currentPoints + 3).where(:team => User.find(r.read_attribute(:ateam)).first_name)
            elsif homescore == awayscore then 
            	currentPointsHome = LeagueTable.find(hteam).read_attribute(:points)
            	currentPointsAway = LeagueTable.find(ateam).read_attribute(:points)
				LeagueTable.update(:points => currentPoints + 1).where(:team => User.find(r.read_attribute(:hteam)).first_name)
				LeagueTable.update(:points => currentPoints + 1).where(:team => User.find(r.read_attribute(:ateam)).first_name)
			else
			end
		end
	end
end
