class AddPlayedToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :played, :boolean
  end
end
