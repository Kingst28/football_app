class AddConcededToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :conceded, :boolean
  end
end
