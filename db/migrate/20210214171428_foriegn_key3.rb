class ForiegnKey3 < ActiveRecord::Migration
  def change
    remove_foreign_key :bids, :teamsheets, column: :player_id, on_delete: :cascade
  end
end
