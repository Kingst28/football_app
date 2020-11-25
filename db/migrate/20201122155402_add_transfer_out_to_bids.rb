class AddTransferOutToBids < ActiveRecord::Migration
  def change
    add_column :bids, :transfer_out, :boolean
  end
end
