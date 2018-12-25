class CreatePlayerstats < ActiveRecord::Migration
  def change
    create_table :playerstats do |t|
      t.integer :player_id
      t.integer :played
      t.integer :scored
      t.integer :scorenum
      t.integer :conceded
      t.integer :concedednum

      t.timestamps null: false
    end
  end
end
