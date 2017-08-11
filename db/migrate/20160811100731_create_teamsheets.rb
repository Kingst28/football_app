class CreateTeamsheets < ActiveRecord::Migration
  def change
    create_table :teamsheets do |t|
      t.integer :user_id
      t.integer :player_id
      t.integer :amount

      t.timestamps
    end
  end
end
