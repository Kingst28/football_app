class AddBidRoundToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :bid_count, :integer, default: 1
  end
end
