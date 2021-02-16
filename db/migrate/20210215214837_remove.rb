class Remove < ActiveRecord::Migration
  def change
    remove_foreign_key :teamsheets, column: :player_id
  end
end
