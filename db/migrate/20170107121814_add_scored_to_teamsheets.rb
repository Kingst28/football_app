class AddScoredToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :scored, :boolean
  end
end
