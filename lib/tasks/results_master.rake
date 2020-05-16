require 'csv'

namespace :csv do

  desc "Import CSV Data"
  task :results_master => :environment do

    csv_file_path = 'lib/tasks/results_masters_prem.csv'

    CSV.foreach(csv_file_path) do |row|
      ResultsMaster.create!({
        :played => row[0],
        :scored => row[1],
        :scorenum => row[2],
        :conceded => row[3],
        :concedednum => row[4],
        :name => row[5],
        :league => row[6]        
      })
      puts "Row added!"
    end
    
    CSV.foreach(csv_file_path) do |row|
      PlayerStat.create!({
        :played => row[0],
        :scored => row[1],
        :scorenum => row[2],
        :conceded => row[3],
        :concedednum => row[4],
        :playerteam => row[5]      
      })
      puts "Row added!"
    end
  end
end