class ChangeColumnDefault < ActiveRecord::Migration
  def change
    change_column_default(:bids, :transfer_out, false)
  end
end
