class CreateMatchdays < ActiveRecord::Migration
  def change
    create_table :matchdays do |t|
      t.integer :matchday_number
      t.string :haflag

      t.timestamps
    end
  end
end
