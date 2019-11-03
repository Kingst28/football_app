class CreateResultsMasters < ActiveRecord::Migration
  def change
    create_table :results_masters do |t|
      t.integer :player_id
      t.boolean :played
      t.boolean :scored
      t.integer :scorenum
      t.boolean :conceded
      t.integer :concedednum

      t.timestamps null: false
    end
  end
end
