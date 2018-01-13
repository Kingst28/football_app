require 'csv'

namespace :csv do

  desc "Import CSV Data"
  task :players => :environment do

    csv_file_path = 'lib/tasks/players.csv'

    CSV.foreach(csv_file_path) do |row|
      Player.create!({
        :name => row[0],
        :position => row[1],
        :teams_id => row[2],        
      })
      puts "Row added!"
    end
  end
end
