class CreateFixtures < ActiveRecord::Migration
  def change
    create_table :fixtures do |t|
      t.integer :matchday
      t.string :hteam 
      t.string :ateam
      t.timestamps
    end
  end
end
