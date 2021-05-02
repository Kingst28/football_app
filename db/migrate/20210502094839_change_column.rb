class ChangeColumn < ActiveRecord::Migration
  def change
    change_column :bids, :refunded, :boolean, :default => false
  end
end
