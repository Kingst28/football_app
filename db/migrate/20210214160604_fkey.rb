class Fkey < ActiveRecord::Migration
  def change
    add_foreign_key :bids, :teamsheets, column: :player_id, on_delete: :cascade
  end
end
