require 'csv'

namespace :csv do

  desc "Import CSV Data"
  task :teams => :environment do

    csv_file_path = 'lib/tasks/teams.csv'

    CSV.foreach(csv_file_path) do |row|
      Team.create!({
        :id => row[0],
        :name => row[1],        
        :account_id => row[2]
      })
      puts "Row added!"
    end
  end
end
