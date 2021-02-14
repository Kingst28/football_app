class ForiegnKey5 < ActiveRecord::Migration
  def change
    add_foreign_key :teamsheets, :bids, column: :player_id, on_delete: :cascade
  end
end
