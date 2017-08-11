require 'csv'

namespace :csv do

  desc "Import CSV Data"
  task :users => :environment do

    csv_file_path = '/Users/JasonKing/Desktop/rails_repo/football_app/lib/tasks/users.csv'

    CSV.foreach(csv_file_path) do |row|
      User.create!({
        :first_name => row[0],
        :last_name => row[1],
        :email => row[2],
        :password_digest => row[3],
        :created_at => row[4],
        :updated_at => row[5],
        :activation_digest => row[6],
        :activated => row[7],
        :activated_at => row[8],
        :reset_digest => row[9], 
        :reset_sent_at => row[10],
        :access => row[11],
        :budget => row[12],       
      })
      puts "Row added!"
    end
  end
end