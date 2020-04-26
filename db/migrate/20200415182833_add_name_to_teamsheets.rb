class AddNameToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :name, :string
  end
end
