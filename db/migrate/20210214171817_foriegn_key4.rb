class ForiegnKey4 < ActiveRecord::Migration
  def change
    remove_foreign_key :bids, column: :player_id
  end
end
