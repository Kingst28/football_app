class AddDefaultValueToLeagueTables < ActiveRecord::Migration
  def change
  	change_column :league_tables, :played, :integer, :default => 0
  	change_column :league_tables, :won, :integer, :default => 0
  	change_column :league_tables, :drawn, :integer, :default => 0
  	change_column :league_tables, :lost, :integer, :default => 0
  	change_column :league_tables, :for, :integer, :default => 0
  	change_column :league_tables, :against, :integer, :default => 0
  	change_column :league_tables, :gd, :integer, :default => 0
  	change_column :league_tables, :points, :integer, :default => 0
  end
end
