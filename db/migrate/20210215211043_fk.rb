class Fk < ActiveRecord::Migration
  def change
    add_foreign_key :bids, :teamsheets, column: :player_id
  end
end
