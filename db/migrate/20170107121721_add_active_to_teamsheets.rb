class AddActiveToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :active, :boolean
  end
end
