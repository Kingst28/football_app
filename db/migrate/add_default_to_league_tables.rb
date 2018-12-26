class AddDefaultToTaken < ActiveRecord::Migration
  def change
    change_column :league_tables, :played, :default => 0
    change_column :league_tables, :won, :default => 0
    change_column :league_tables, :drawn, :default => 0
    change_column :league_tables, :lost, :default => 0
    change_column :league_tables, :for, :default => 0
    change_column :league_tables, :against, :default => 0
    change_column :league_tables, :gd, :default => 0
    change_column :league_tables, :points, :default => 0
  end
end
