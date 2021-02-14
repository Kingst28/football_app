class ForiegnKey3 < ActiveRecord::Migration
  def change
    remove_foreign_key :bids, :teamsheets
  end
end
