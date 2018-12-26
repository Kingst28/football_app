class CreateLeagueTables < ActiveRecord::Migration
  def change
    create_table :league_tables do |t|
      t.string :team
      t.integer :played, :default => 0
      t.integer :won, :default => 0
      t.integer :drawn, :default => 0
      t.integer :lost, :default => 0
      t.integer :for, :default => 0
      t.integer :against, :default => 0
      t.integer :gd, :default => 0
      t.integer :points, :default => 0

      t.timestamps
    end
  end
end
