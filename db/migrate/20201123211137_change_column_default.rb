class ChangeColumnDefault < ActiveRecord::Migration
  def change
    change_column_default(:bids, :transfer_out, 0)
  end
end
