class AddRefundedToBids < ActiveRecord::Migration
  def change
    add_column :bids, :refunded, :boolean
  end
end
