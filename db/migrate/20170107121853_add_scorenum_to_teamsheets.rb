class AddScorenumToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :scorenum, :integer
  end
end
