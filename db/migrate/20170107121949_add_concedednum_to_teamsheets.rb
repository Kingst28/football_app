class AddConcedednumToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :concedednum, :integer
  end
end
