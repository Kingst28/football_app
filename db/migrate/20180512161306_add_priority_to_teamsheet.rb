class AddPriorityToTeamsheet < ActiveRecord::Migration
  def change
    add_column :teamsheets, :priority, :integer
  end
end
