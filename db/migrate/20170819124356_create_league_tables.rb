class CreateLeagueTables < ActiveRecord::Migration
  def change
    create_table :league_tables do |t|
      t.string :team
      t.integer :played
      t.integer :won
      t.integer :drawn
      t.integer :lost
      t.integer :for
      t.integer :against
      t.integer :gd
      t.integer :points

      t.timestamps
    end
  end
end
