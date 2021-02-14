class ForiegnKey < ActiveRecord::Migration
  def change
    add_foreign_key :teamsheets, :player_id 
    add_foreign_key :player_id, :bids
  end
end
