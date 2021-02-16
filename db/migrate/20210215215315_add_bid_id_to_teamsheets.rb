class AddBidIdToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :bid_id, :integer
    add_index :teamsheets, :bid_id
  end
end
