class ForiegnKey2 < ActiveRecord::Migration
  def change
    add_foreign_key :teamsheets, :player
    add_foreign_key :player, :bids
  end
end
