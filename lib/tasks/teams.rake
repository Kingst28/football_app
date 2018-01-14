require 'csv'

namespace :csv do

  desc "Import CSV Data"
  task :teams => :environment do

    csv_file_path = 'lib/tasks/teams.csv'

    CSV.foreach(csv_file_path) do |row|
      Team.create!({
        :name => row[0],        
      })
      puts "Row added!"
    end
  end
end
