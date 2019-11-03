class AddAccountToBids < ActiveRecord::Migration
  def change
    add_column :bids, :account_id, :integer
    add_index  :bids, :account_id
  end
end
